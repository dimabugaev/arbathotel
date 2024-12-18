{{ config(
    materialized='table',
    indexes=[
      {'columns': ['plan_arrival_date', 'plan_departure_date']},
      {'columns': ['arrival_date', 'departure_date']},
      {'columns': ['booking_number']},
      {'columns': ['booking_id']},
      {'columns': ['main_booking_number']},
    ]
) }}

with raw_bookings as (
    select * from {{ source('bnovo', 'bookings') }}
)
,created_users_ids as (
    select * from {{ source('bnovo', 'booking_users_link') }}
)
select
    rb.source_id,
    rb.id::int as booking_id,
    rb.hotel_id::int,
    rb.number as booking_number,
    coalesce(rb.main_booking_number, number) as main_booking_number,
    rb.group_id::int as group_id,
    rb.prices_services_total::decimal(18,2),
    rb.prices_rooms_total::decimal(18,2),
    rb.provided_total::decimal(18,2),
    rb.payments_total::decimal(18,2),
    rb.prices_services_total::decimal(18,2),
    rb.prices_rooms_total::decimal(18,2),
    rb.status_id::int as status_id,
    rb.status_name,
    rb.name contact_name,
    rb.surname contact_surname,
    rb.phone contact_phone,
    rb.cancel_date::timestamp as cancel_date,
    rb.create_date::timestamp as created_at,
    rb.arrival::timestamp as plan_arrival_date,
    rb.departure::timestamp as plan_departure_date,
    rb.arrival_date as arrival_date,
    rb.departure_date as departure_date,
    rb.real_arrival::timestamp,
    rb.real_departure::timestamp,
    rb.adults::decimal(10,0),
    rb.children::decimal(10,0),
    rb.date_update as updated_at,
    cu.user_id
from
    raw_bookings rb left join created_users_ids cu on rb.source_id = cu.source_id and rb.id = cu.booking_id