with raw_ufms_data as (
    select * from {{ source('bnovo', 'ufms_data') }}
)
select
    source_id,
	id::int as application_id,
    hotel_id::int as hotel_id,
    booking_id::int,
    customer_id::int,
    status::int,
    scala_id,
    scala_number,
    last_error,
    last_attempt_date::timestamp,
    create_date::timestamp,
    update_date::timestamp,
    scala_status,
    citizenship_id,
    arrival::timestamp,
    departure::timestamp,
    customer_name,
    customer_surname,
	date_update as updated_at
from
    raw_ufms_data