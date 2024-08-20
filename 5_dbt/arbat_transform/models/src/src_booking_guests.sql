with raw_guests as (
    select * from {{ source('bnovo', 'guests') }}
),
booking_guests_links as (
    select * from {{ source('bnovo', 'booking_guests_link') }}
)
select
    bl.booking_id::int,
    rg.id::int,
    rg.source_id,
    rg.citizenship_id::int,
    rg.citizenship_name,
    rg.name,
    rg.surname,
    rg.middlename,
    rg.birthdate::date,
    rg.document_type::int,
    rg.document_series,
    rg.document_number,
    rg.address_free,
    rg.date_update as guest_updated_at,
    bl.date_update as booking_updated_at
from
    raw_guests rg inner join booking_guests_links bl
        on rg.id = bl.guest_id