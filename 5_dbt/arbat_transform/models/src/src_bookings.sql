{{ config(
    materialized='table',
    indexes=[
      {'columns': ['plan_arrival_date', 'plan_departure_date']},
      {'columns': ['arrival_date', 'departure_date']},
      {'columns': ['booking_number']},
      {'columns': ['main_booking_number']},
    ]
) }}

with raw_bookings as (
    select * from {{ source('bnovo', 'bookings') }}
)
select
    source_id,
    id::int as booking_id,
    hotel_id::int,
    number as booking_number,
    coalesce(main_booking_number, number) as main_booking_number,
    group_id::int as group_id,
    prices_services_total::decimal(18,2),
    prices_rooms_total::decimal(18,2),
    provided_total::decimal(18,2),
    payments_total::decimal(18,2),
    status_id::int as status_id,
    status_name,
    cancel_date::timestamp as cancel_date,
    create_date::timestamp as created_at,
    arrival::timestamp as plan_arrival_date,
    departure::timestamp as plan_departure_date,
    arrival_date as arrival_date,
    departure_date as departure_date,
    real_arrival::timestamp,
    real_departure::timestamp,
    adults::decimal(10,0),
    children::decimal(10,0),
    date_update as updated_at
from
    raw_bookings