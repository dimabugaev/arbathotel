with qr_aq as (
	select
		rpn id_aq,
		operation_type,
		file_key,
		device_number terminal_number,
		device_name,
		coalesce(order_number,'') order_number,
		coalesce(description, '') description,
		to_timestamp(operation_data, 'DD.MM.YYYY HH24:MI:SS')::timestamp operation_data,
		to_date(processing_data, 'DD.MM.YYYY') processing_data,
		operation_sum::decimal(18,2) operation_sum,
		commission::decimal(18,2) commission,
		to_transaction::decimal(18,2) to_transaction,
		sum(to_transaction::decimal(18,2)) over (partition by file_key) bank_payment_sum,
		sum(operation_sum::decimal(18,2)) over (partition by file_key) total_operation_sum,
		sum(commission::decimal(18,2)) over (partition by file_key) total_commision_sum
	from 
        {{ source('banks', 'psb_acquiring_term') }}
)
,bank_payments_for_refund as (
	select
		id,
		source_id,
		date_transaction,
		(in_summ - out_summ)::decimal(18,2) payment_sum,
		payment_purpose,
		substring(payment_purpose FROM '[0-9]+\.?[0-9]*')::decimal(18,2) AS extracted_commission
	from
        {{ ref('src_bank_psb_payments') }}
	where
		position('Возмещение средств ТСП. Удержана комиссия:' in payment_purpose) = 1	
)
select
	aq.file_key,
	aq.operation_type,
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
	max(bp.extracted_commission) extracted_commission,
	max(bp.id) bank_payment_id,
	max(bp.source_id) source_id,
	max(bp.payment_purpose) bank_payment_purpose
from
	qr_aq aq left join bank_payments_for_refund	bp 
		on aq.processing_data = bp.date_transaction and aq.bank_payment_sum = bp.payment_sum --and aq.recipient_name = bp.contragent
group by
	aq.file_key,
	aq.id_aq,
	aq.operation_type