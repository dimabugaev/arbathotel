{{ config(
    materialized='snapshot',
    unique_key='booking_id',
    strategy='timestamp',
    updated_at='updated_at'
) }}

select
    *
from 
    {{ ref('src_bookings') }}