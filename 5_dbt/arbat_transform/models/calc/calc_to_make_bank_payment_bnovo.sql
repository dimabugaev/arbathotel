with psb_distributed_by_booking_payments as (
    select * from {{ ref('calc_psb_payments_distributed') }}
    where booking_id is not null and distributed_sum > 0
),
bnovo_current_bank_payments as (
    select *
    from
        {{ ref('calc_bnovo_payments_by_bookings') }}
    where type_id = '1' -- bank payment

)

select
    {{ dbt_utils.generate_surrogate_key(['dp.booking_id', 'dp.payment_id']) }} as task_key,
    dp.source_id,
    dp.booking_id,
    bo.booking_number,
    'create_payment' as action,
    'Бронирование ' || bo.booking_number as reason,
    '1' as is_for_booking,
    dp.hotel_supplier_id,
    dp.supplier_id,
    1 as type_id,
    1 as create_booking_payment,
    coalesce(dp.distributed_sum, 0) - coalesce(bp.sum_payment_in_bnovo, 0) as amount,
    dp.payment_id as temp_payment_id,
    to_char(dp.created_at, 'DD-MM-YYYY') as paid_date,
    '00' as paid_date_hour,
    '00' as paid_date_minute
    
from
    psb_distributed_by_booking_payments dp left join 
        bnovo_current_bank_payments bp 
            on dp.source_id = bp.source_id and dp.booking_id = bp.booking_id
                left join {{ ref('src_bookings') }} bo on dp.booking_id = bo.booking_id
where 
    coalesce(dp.distributed_sum, 0) - coalesce(bp.sum_payment_in_bnovo, 0) > 0        