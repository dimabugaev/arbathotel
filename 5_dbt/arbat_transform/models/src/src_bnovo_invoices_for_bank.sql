with raw_invoices as (
    select * from {{ source('bnovo', 'invoices') }}
),
raw_suppliers as (
    select * from {{ source('bnovo', 'suppliers') }}
)
select
    i.source_id,
    i.id::int as invoice_id,
    upper(trim(i.number)) as invoice_number,
    {{ convert_to_cyrillic('upper(trim(i.number))') }} as cyrillic_invoice_number,
    case 
        when i.booking_id = '0' then
            true
        else
            false    
    end is_group_invoice,
    i.booking_id::int as booking_id,
    i.group_id::int as group_id,
    i.amount::decimal(18,2) as amount,
    i.payed_amount::decimal(18,2) as payed_amount,
    case 
        when i.amount = i.payed_amount then
            true
        else
            false
    end as is_fully_payed,
    i.amount::decimal(18,2) - i.payed_amount::decimal(18,2) as to_pay,
    s.name as supplier_for_pay,
    s.account as account_for_pay,
    s.correspondent_account as corr_account_for_pay,
    s.bik as bik_for_pay,
    s.bank as bank_for_pay,
    i.hotel_supplier_id,
    i.supplier_id,
    i.create_date::timestamp as created_at,
    i.date_update as updated_at
from
    raw_invoices i left join raw_suppliers s
        on i.hotel_supplier_id = s.id and i.source_id = s.source_id
where
    i.type_id = '1'