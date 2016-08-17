select distinct     o.id, o.restaurant_id as restaurant_id, o.user_id, o.zone_id, o.created_at,
                    date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at)) AS d_o_w,
                    date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) AS h_o_d,
                    ud.geo_lat as user_lat, ud.geo_long as user_long,
                    r.geo_lat as rest_lat, r.geo_long as rest_long,
                    distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000 as rest_to_cust_dis_m,
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
join        (
            select            rcom.name AS company_name,
                              case when count(*) >1 then 1 else 0 end as chain
            from        public.restaurant r
            join        public.restaurant_account ra
            on          ra.id = r.id
            join        public.restaurant_invoice_account ria
            on          ria.id = ra.invoice_account_id
            join        public.restaurant_company rcom
            on          rcom.id = ria.company_id
            group by    company_name
            limit 10) ch
ON          ch.company_name = rcom.name
where       o.created_at::date between '2016-01-01' and '2016-07-31'
limit 100



------------------------------
select      r.id, r.restaurant_id, date_part(hr, convert_timezone(c.city_tz_name, ord.created_at)) as h_o_d,
            r.zone_id
from        public.restaurant r
join        public.city c
on          c.country_id = r.country_id
right join

(select      pos.h_o_d, pos.restaurant_id, pos.zone_id
  from        (
                select distinct     o.id, o.restaurant_id as restaurant_id, o.user_id, o.zone_id, o.created_at,
                                    date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at)) AS d_o_w,
                                    date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) AS h_o_d,
                                    ud.geo_lat as user_lat, ud.geo_long as user_long,
                                    r.geo_lat as rest_lat, r.geo_long as rest_long,
                                    distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000 as rest_to_cust_dis_m,
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
                join        (
                            select      rcom.name AS company_name, case when count(*) >1 then 1 else 0 end as chain
                            from        public.restaurant r
                            join        public.restaurant_account ra
                            on          ra.id = r.id
                            join        public.restaurant_invoice_account ria
                            on          ria.id = ra.invoice_account_id
                            join        public.restaurant_company rcom
                            on          rcom.id = ria.company_id
                            group by    company_name
                            limit 10) ch
                ON          ch.company_name = rcom.name
                where       o.created_at::date between '2016-01-01' and '2016-07-31'
                limit 100) pos) positive


select      r.id, r.restaurant_id, date_part(hr, convert_timezone(c.city_tz_name, ord.created_at)) as h_o_d,
            r.zone_id
from        public.restaurant r
join        public.city c
on          c.country_id = r.country_id



select  *
from    public.orders o
join    public.restaurant_hours hr
on      o.restaurant_id = hr.restaurant_id
where   date_part(hr,  o.created_at) between hr.open_time and hr.close_time limit 5;
and     o.id = 9638585


select * from public.delivery_zone limit 5;
select * from public.restaurant limit 5;
select * from public.delivery_zone limit 5;
select * from public.user_address limit 5;
select * from public.restaurant_hours where restaurant_id = 15521
