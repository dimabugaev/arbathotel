with bnovo_payments_booking as (
    select
        *
    from
        {{ ref('src_bnovo_payments') }}
),
payments_no_group as (
    select
        source_id,
        booking_id,
        {# case
            when sum_payment > 0 or upper(reason) = 'ПЕРЕНОС ОПЛАТЫ' then
                false
            else
                true
        end as debit, #}
        type_id::int as type_id,
        paid_date,
        case
            when upper(reason) = 'ПЕРЕНОС ОПЛАТЫ' or sum_payment < 0 then
                0
            else    
                sum_payment 
        end as sum_payment_in_bnovo,
        case
            when upper(reason) = 'ПЕРЕНОС ОПЛАТЫ' or sum_payment < 0 then
                sum_payment
            else    
                0 
        end as sum_corrected_in_bnovo
    from
        bnovo_payments_booking
)
select
    source_id,
    booking_id,
    --debit,
    type_id,
    min(paid_date) as first_payment_date,
    sum(sum_payment_in_bnovo) as sum_payment_in_bnovo,
    sum(sum_corrected_in_bnovo) as sum_corrected_in_bnovo
from 
    payments_no_group
group by
    source_id,
    booking_id,
    --debit,
    type_id    