with raw_sources as (
    select * from {{ source('operate', 'sources') }})
select
    id source_id,
    source_external_key,
    source_name, 
    source_type, 
    source_income_debt
from raw_sources