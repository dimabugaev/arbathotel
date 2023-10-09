with psb_for_distrib as (
    select 
        *
    from
        {{ ref('calc_psb_payments_for_distrib') }}
),
bnovo_bank_invoices_for_distrib as (
    select
        *
    from
        {{ ref('calc_bank_invoices_by_booking_for_distrib') }}
),
psb_stage_first as (
    select
        source_id,
        supplier_id,
        hotel_supplier_id,
        payment_key,
        payment_id,
        cyrillic_key_invoice,
        created_at,
        sum(to_distrib) over (partition by cyrillic_key_invoice order by created_at, payment_id) - to_distrib begin_sum,
        sum(to_distrib) over (partition by cyrillic_key_invoice order by created_at, payment_id) end_sum
    from
        psb_for_distrib    
),
bnovo_booking_temp as (
    select
        source_id,
        booking_id,
        cyrillic_invoice_number,
        booking_created_ad,
        1 as number_distrib,
        provided_total
    from
        bnovo_bank_invoices_for_distrib
    where
        cancel_date is null

    union all

    select distinct
        source_id,
        null::int,
        cyrillic_invoice_number,
        null::timestamp,
        2,
        9999999999999999
    from
        bnovo_bank_invoices_for_distrib     
),
bnovo_booking_first as (
    select
        source_id,
        booking_id,
        cyrillic_invoice_number,
        booking_created_ad,
        sum(provided_total) over (partition by cyrillic_invoice_number order by number_distrib, booking_created_ad, booking_id) - provided_total as begin_sum,
        sum(provided_total) over (partition by cyrillic_invoice_number order by number_distrib, booking_created_ad, booking_id) as end_sum
    from
        bnovo_booking_temp 
)

select
    b.source_id,
    b.payment_key,
    b.payment_id,
    b.supplier_id,
    b.hotel_supplier_id,
    b.cyrillic_key_invoice,
    b.created_at,
    b.begin_sum as bank_begin,
    b.end_sum as bank_end,
    i.booking_id,
    i.cyrillic_invoice_number,
    i.booking_created_ad,
    i.begin_sum,
    i.end_sum,
    case 
        when b.end_sum > i.end_sum then
            i.end_sum
        else
            b.end_sum
    end - 
    case 
        when b.begin_sum > i.begin_sum then
            b.begin_sum
        else
            i.begin_sum
    end as distributed_sum 
from 
    psb_stage_first b left join bnovo_booking_first i
        on b.cyrillic_key_invoice = i.cyrillic_invoice_number and b.source_id = i.source_id
            and b.end_sum > i.begin_sum and b.begin_sum < i.end_sum         
