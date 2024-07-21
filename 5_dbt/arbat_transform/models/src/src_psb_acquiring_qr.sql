with qr_aq as (
	select 
		id_payment id_aq,
		file_key,
		terminal_number,
		tsp_name device_name,
		'' order_number,
		coalesce(about_payment,'') description,
		to_timestamp(date_time, 'DD.MM.YYYY HH24:MI:SS')::timestamp operation_data,
		to_date(date_time, 'DD.MM.YYYY HH24:MI:SS') processing_data,
		operation_sum::decimal(18,2) operation_sum,
		operation_com::decimal(18,2) commission,
		to_tramsaction::decimal(18,2) to_transaction,
		sum(to_tramsaction::decimal(18,2)) over (partition by file_key) bank_payment_sum,
		sum(operation_sum::decimal(18,2)) over (partition by file_key) total_operation_sum,
		sum(operation_com::decimal(18,2)) over (partition by file_key) total_commision_sum,
		substring(payer_name FROM '^[^ _]*') recipient_name
	from 
	{{ source('banks', 'psb_acquiring_qr') }} 
)
,bank_payments_for_refund as (
	select
		id,
		source_id,
		date_transaction,
		(in_summ - out_summ)::decimal(18,2) payment_sum,
		payment_purpose,
		substring(contragent FROM '^[^ _]*') contragent
	from
        {{ ref('src_bank_psb_payments') }}
	where 
		payment_purpose = 'Платеж СБП'	
)
select 
	aq.id_aq,
	max(aq.terminal_number) terminal_number,
	max(aq.device_name) device_name,
	max(aq.order_number) order_number,
	max(aq.description) description,
	max(aq.operation_data) operation_data,
	max(aq.processing_data) processing_data,
	max(aq.operation_sum) operation_sum,
	max(aq.commission) commission,
	max(aq.to_transaction) to_transaction,
	max(aq.bank_payment_sum) bank_payment_sum,
	max(aq.total_operation_sum) total_operation_sum,
	max(aq.total_commision_sum) total_commision_sum,
	max(bp.id) bank_payment_id,
	max(bp.source_id) source_id,
	max(bp.payment_purpose) bank_payment_purpose
from
	qr_aq aq left join bank_payments_for_refund	bp 
		on aq.processing_data = bp.date_transaction and aq.to_transaction = bp.payment_sum and aq.recipient_name = bp.contragent
group by 
	aq.id_aq