{# with aq_qr_refund as (
    select * from {{ ref('src_psb_acquiring_qr_refund') }} where bank_payment_id is null
)
,aq_qr as (
    select * from {{ ref('src_psb_acquiring_qr') }} where bank_payment_id is null
)
,aq_term as (
    select * from {{ ref('src_psb_acquiring_term') }} where bank_payment_id is null
)
select #}

