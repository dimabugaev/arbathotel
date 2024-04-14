{{
  config(
	materialized = 'table',
	)
}}

with selected_bookings as(
	select 
		*
	from
		{{ ref('src_bookings') }} 
	where
		plan_arrival_date::date > (now() - interval '2 MONTH')::date
        and plan_departure_date::date < (now() + interval '2 DAY')::date
		and status_id <> 2
)
select
	sbh.name as hotel,
    sb.plan_departure_date::date as departure_date,
    count(distinct sb.booking_id)
from
    selected_bookings sb left join {{ ref('src_bnovo_hotels') }} sbh on sb.hotel_id = sbh.hotel_id
group by
    sbh.name,
    sb.plan_departure_date::date    
