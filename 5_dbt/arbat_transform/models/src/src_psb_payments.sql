with raw_docs as (
    select * from {{ source('banks', 'psb_docs') }}
),
raw_strings as (
    select * from {{ source('banks', 'psb_docs_rows') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['d.id', 's.description', 's.summa_rur']) }} as payment_key,
    d.source_id,
    d.id payment_id,
    d.number_doc,
    d.row_date::date date_doc,
    s.row_date::date date_string_doc,
    case
        when not s.debit then
            s.summa_rur::decimal(18,2)
        else
            0     
    end::decimal(18,2) as sum_income,
    case
        when s.debit then
            s.summa_rur::decimal(18,2)
        else
            0     
    end::decimal(18,2) as sum_spend,
    summa_rur::decimal(18,2) as summa_rur,
    case
        when s.debit then
            - s.summa_rur::decimal(18,2)
        else
            s.summa_rur::decimal(18,2)     
    end::decimal(18,2) as sum_total,
    s.description as remark,
    s.debit,
    so.source_external_key as account,
    s.row_date::timestamp as created_at,
    s.date_update as updated_at
from
    raw_docs d left join raw_strings s 
    on d.id = s.doc_id and d.source_id = s.source_id
        left join {{ ref('src_sources') }} so
            on s.source_id = so.source_id