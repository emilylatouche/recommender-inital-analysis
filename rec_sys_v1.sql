select      o.id, o.restaurant_id as restaurant_id, o.user_id, o.zone_id,
            date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at)) AS d_o_w,
            date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) AS local_acknowledged_at,
            ud.geo_lat as user_lat, ud.geo_long as user_long, r.zone_id,
            r.geo_lat as rest_lat, r.geo_long as rest_long,
            distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000 as rest_to_cust_dis_m,
            ch.chain,
            '1' as pos_neg_data
from        public.orders o
left join   public.user_address ud
on          o.id = ud.id
left join   public.restaurant r
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
            select      rcom.name AS company_name, case when count(*) > 1 then 1 else 0 end as chain
            from        public.restaurant r
            join        public.restaurant_account ra
            on          ra.id = r.id
            join        public.restaurant_invoice_account ria
            on          ria.id = ra.invoice_account_id
            join        public.restaurant_company rcom
            on          rcom.id = ria.company_id
            group by    company_name) ch
ON          ch.company_name = rcom.name
where       o.created_at::date between '2016-01-01' and '2016-07-31'

limit 5



------------------------------


select      pos.h_o_d, pos.restaurant_id, pos.zone_id
from        (
            select      o.id, o.restaurant_id as restaurant_id, o.user_id, o.zone_id,
                        date_part(dayofweek,convert_timezone(c.city_tz_name, o.created_at) AS d_o_w,
                        date_part(hr, convert_timezone(c.city_tz_name, o.created_at)) AS local_acknowledged_at,
                        ud.geo_lat as user_lat, ud.geo_long as user_long, r.zone_id,
                        r.geo_lat as rest_lat, r.geo_long as rest_long,
                        distance_km(r.geo_long,r.geo_lat,ud.geo_long,ud.geo_lat) * 1000 as restaurant_to_customer_distance_meters,
                        '1' as pos_neg_data
            from        public.orders o
            left join   public.user_address ud
            on          o.id = ud.id
            left join   public.restaurant r
            on          o.restaurant_id = r.id
            join        public.city c
            on          c.city_id = r.city_id
            where       o.created_at::date between '2016-01-01' and '2016-07-31'
            limit 5) pos
join        (select     hr.restaurant_id, res.zone_id, hr.open_time, hr.close_time
            from        public.restaurant_hours hr
            join        public.restaurant res
            on          res.id = hr.restaurant_id) neg
on




select * from public.orders
JOIN
(select     hr.restaurant_id, res.zone_id, hr.open_time, hr.close_time
            from        public.restaurant_hours hr
            join        public.restaurant res
            on          res.id = hr.restaurant_id) hr
on         extract(hr from o.created_at) between hr.open_time and hr.close_time

limit 5


select * from public.orders limit 5;
select * from public.delivery_zone limit 5;
select * from public.restaurant limit 5;
select * from public.delivery_zone limit 5;
select * from public.user_address limit 5;
select * from public.restaurant_hours where restaurant_id = 15521
