with raw_payments as (
    select * from {{ source('bnovo', 'payments') }}
),
raw_payments_record as (
    select * from {{ source('bnovo', 'payment_records') }}
),
raw_suppliers as (
    select * from {{ source('bnovo', 'suppliers') }}
)
select
    {{ dbt_utils.generate_surrogate_key(['p.id', 'pr.item_id', 'pr.method_id', 'pr.subject_id', 'pr.service_id', 'pr.service_name', 'pr.supplier_id', 'pr.type_id','pr.reason']) }} as payment_key,
    p.source_id,
    p.id::int as payment_id,
    pr.hotel_supplier_id::int as supplier_id,
    pr.booking_id::int as booking_id,
    p.external_booking_id::int as external_booking_id,
    p.external_payment_id::int as external_payment_id,
    pr.type_id::int as type_id,
    pr.item_id::int as item_id,
    nullif(pr.method_id, '')::int as method_id,
    nullif(pr.subject_id, '')::int as subject_id,
    nullif(pr.service_id, '')::int as service_id,
    nullif(pr.supplier_id, '')::int as external_supplier_id,
    nullif(pr.transferred_refund_id, '')::int as transferred_refund_id,

    pr.service_name as service_name,
    pr.amount::decimal(18,2) as sum_payment,

    pr.name as name_of_pay,
    
    pr.reason,
    pr.paid_date::date as paid_date,
    p.create_date::timestamp as created_at,
    pr.date_update as updated_at
from 
    raw_payments p inner join raw_payments_record pr
        on p.id = pr.payment_id
where
    pr.booking_id is not null and pr.booking_id <> '0'

