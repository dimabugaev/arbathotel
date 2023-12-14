with raw_hotels as (
    select * from {{ source('bnovo', 'hotels') }}
)
select
    id::int as hotel_id,
    name,
    date_update as updated_at
from
    raw_hotels