with group_invoices as (
    select
        *
    from 
        {{ ref('src_bnovo_invoices_for_bank') }}
    where
        is_group_invoice
),
group_bookings as (
    select 
        *
    from
        {{ ref('src_bookings') }}
    where
        group_id is not null
),
single_invoices as (
    select
        *
    from 
        {{ ref('src_bnovo_invoices_for_bank') }}
    where
        not is_group_invoice
),
single_bookings as (
    select 
        *
    from
        {{ ref('src_bookings') }}
--    where
--        group_id is null
),
invoices_by_bookings as (
    select
        i.source_id,
        i.invoice_id,
        i.invoice_number,
        i.cyrillic_invoice_number,
        i.is_group_invoice,
        i.booking_id,
        i.group_id,
        i.amount,
        i.payed_amount,
        i.is_fully_payed,
        i.to_pay,
        i.supplier_for_pay,
        i.account_for_pay,
        i.corr_account_for_pay,
        i.bik_for_pay,
        i.bank_for_pay,
        i.created_at as invoice_created_at,
        i.updated_at as invoice_updated_at,
        i.supplier_id,
        i.hotel_supplier_id,

        b.booking_id as founded_booking_id,
        prices_rooms_total,
        b.created_at as booking_created_ad,
        b.provided_total,
        b.payments_total,
        b.cancel_date

    from 
        group_invoices i left join group_bookings b
            on i.group_id = b.group_id
    union all

    select
        i.source_id,
        i.invoice_id,
        i.invoice_number,
        i.cyrillic_invoice_number,
        i.is_group_invoice,
        i.booking_id,
        i.group_id,
        i.amount,
        i.payed_amount,
        i.is_fully_payed,
        i.to_pay,
        i.supplier_for_pay,
        i.account_for_pay,
        i.corr_account_for_pay,
        i.bik_for_pay,
        i.bank_for_pay,
        i.created_at,
        i.updated_at,
        i.supplier_id,
        i.hotel_supplier_id,


        b.booking_id,
        prices_rooms_total,
        b.created_at,
        b.provided_total,
        b.payments_total,
        b.cancel_date
    from
        single_invoices i left join single_bookings b
            on i.booking_id = b.booking_id
)
select
    ib.source_id,
    ib.cyrillic_invoice_number,
    ib.invoice_id,
    ib.amount as invoice_amount,
    ib.invoice_created_at,
    ib.founded_booking_id as booking_id,
    ib.provided_total,
    ib.payments_total,
    ib.booking_created_ad,
    ib.cancel_date
from
    invoices_by_bookings ib
where
    founded_booking_id is not null

order by
    cyrillic_invoice_number,
    booking_created_ad
