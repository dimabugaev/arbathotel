{{
  config(
	materialized = 'table',
	)
}}

select
    ud.hotel_id,
    hl.name as hotel_name,
    ud.booking_id,
    bk.booking_number,
    ud.status,
    ud.scala_id,
    ud.scala_number,
    ud.scala_status,
    ud.last_error,
    ud.last_attempt_date,
    ud.create_date,
    ud.update_date,
    ud.arrival,
    ud.departure,
    ud.customer_id,
    bg.name,
    bg.surname
from
    {{ ref('src_ufms_data') }} ud left join {{ ref('src_bnovo_hotels') }} hl on ud.hotel_id = hl.hotel_id
        left join {{ ref('src_bookings') }} bk on ud.booking_id = bk.booking_id
        left join {{ ref('src_booking_guests') }} bg on ud.customer_id = bg.id