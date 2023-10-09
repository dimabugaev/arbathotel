with raw_bookings as (
    select * from {{ source('bnovo', 'bookings') }}
)
select
    source_id,
    id::int as booking_id,
    number as booking_number,
    group_id::int as group_id,
    prices_services_total::decimal(18,2),
    prices_rooms_total::decimal(18,2),
    provided_total::decimal(18,2),
    payments_total::decimal(18,2),
    status_id::int as status_id,
    cancel_date::date as cancel_date,
    create_date::timestamp as created_at,
    date_update as updated_at
from
    raw_bookings