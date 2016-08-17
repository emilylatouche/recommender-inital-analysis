
------------determine what restaurants are chains-------------

drop table if exists chain;
create temp table chain as
      select      rcom.name AS company_name,
                  case when count(*) >1 then 1 else 0 end as chain
      from        public.restaurant r
      join        public.restaurant_account ra
      on          ra.id = r.id
      join        public.restaurant_invoice_account ria
      on          ria.id = ra.invoice_account_id
      join        public.restaurant_company rcom
      on          rcom.id = ria.company_id
      group by    company_name;

------------create the negative example set-----------------

drop table if exists neg_examples_set;
create temp table neg_examples_set as
      select        r.id as  neg_id, r.zone_id as neg_zone, pos.h_o_d as neg_hod, pos.d_o_w as neg_dow,
                    pos.id as pos_id, pos.zone_id as pos_zone, pos.h_o_d as pos_hod, pos_order_id
      from          public.restaurant r
      join          public.restaurant_hours hr
      on            r.id = hr.restaurant_id
      left join
                    (select distinct    o.id as pos_order_id, r.id, date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) as h_o_d,
                                date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at)) AS d_o_w,
                                r.zone_id
                    from        public.orders o
                    join        public.restaurant r
                    on          o.restaurant_id = r.id
                    join        public.city c
                    on          c.country_id = r.country_id
                    where       o.created_at::date between '2016-07-01' and '2016-07-31') pos
      on pos.zone_id = r.zone_id
      and pos.h_o_d between hr.open_time and hr.close_time
      and pos.d_o_w between hr.day_range_end and hr.day_range_end
      where r.id != pos.id;

----------------create positive examples training set-------------------


drop table if exists pos_examples;
create temp table pos_examples as
      select distinct     o.id, o.restaurant_id as restaurant_id,  o.zone_id,
                  date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at)) AS d_o_w,
                  date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) AS h_o_d,
                  round(distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000,2) as rest_to_cust_dis_m,
                  ch.chain,
                  '1' as pos_neg_data
      from        public.orders o
      join        public.user_address ud
      on          o.user_id = ud.user_id
      and         o.address_id = ud.id
      join        public.restaurant r
      on          o.restaurant_id = r.id
      join        public.city c
      on          c.country_id = r.country_id
      join        public.restaurant_account ra
      on          ra.id = r.id
      join        public.restaurant_invoice_account ria
      on          ria.id = ra.invoice_account_id
      join        public.restaurant_company rcom
      on          rcom.id = ria.company_id
      join        chain ch
      ON          ch.company_name = rcom.name
      where       o.created_at::date between '2016-07-01' and '2016-07-31';

-------------------------create negative example training set---------------

drop table if exists neg_examples;
create temp table neg_examples as
      select distinct     neg.pos_order_id, neg.neg_id as restaurant_id, neg.neg_zone as zone_id,
                        neg.neg_dow as d_o_w, neg.neg_hod AS h_o_d, neg.rest_to_cust_dis_m ,
                        ch.chain, '0' as pos_neg_data
      from    (select distinct     neg_id , neg_zone, neg_hod, n.pos_order_id, pos_id, n.neg_dow,
                          round(distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000,2) as rest_to_cust_dis_m,
                          RANK() OVER  (PARTITION BY  neg_zone, neg_hod, pos_id, pos_order_id
                          ORDER BY (distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000) ASC)
                          as rnk
              from        neg_examples_set n
              join        public.orders o
              on          n.pos_order_id = o.id
              join        public.user_address ud
              on          o.user_id = ud.user_id
              and         o.address_id = ud.id
              join        public.restaurant r
              on          n.neg_id = r.id) neg
      join        public.restaurant r
      on          neg.neg_id = r.id
      join        public.city c
      on          c.country_id = r.country_id
      join        public.restaurant_account ra
      on          ra.id = r.id
      join        public.restaurant_invoice_account ria
      on          ria.id = ra.invoice_account_id
      join        public.restaurant_company rcom
      on          rcom.id = ria.company_id
      join        chain ch
      ON          ch.company_name = rcom.name
      where rnk = 1
      limit 50;

------------------------merge positive and negative-------------

create temp table rec_training_set AS
     select * from neg_examples
     union all
     select * from pos_examples