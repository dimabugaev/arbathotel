with aq_qr_refund as (
    select * from {{ ref('src_psb_acquiring_qr_refund') }} where bank_payment_id is null
)
,aq_qr as (
    select * from {{ ref('src_psb_acquiring_qr') }} where bank_payment_id is null
)
,aq_term as (
    select * from {{ ref('src_psb_acquiring_term') }} where bank_payment_id is null
)
,aq_all as (
    select
        id_aq,  
        operation_type,
        terminal_number,
        order_number,
        description,
        operation_data, 
        operation_sum operation_sum,
        commission commission,
        source_id,
        hotel_id
    from 
       aq_term
    union all
    select
        id_aq,  
        'payment_qr' operation_type,
        terminal_number,
        order_number,
        description,
        operation_data, 
        operation_sum,
        commission,
        source_id,
        hotel_id
    from 
       aq_qr
    union all
    select
        id_aq,  
        'refund_qr' operation_type,
        terminal_number,
        order_number,
        description,
        operation_data, 
        operation_sum,
        commission,
        source_id,
        hotel_id
    from 
       aq_qr_refund 
)
select
    id_aq,
    operation_type,
    terminal_number,
    order_number,
    description,
    operation_data,
    operation_data::date date_transaction,
    operation_sum,
    commission,
    source_id,
    hotel_id
from
    aq_all 