with refund_aq as (
	select
		id_payment_refund id_aq,
		file_key,
		terminal_number,
		payer_tsp_name device_name,
		coalesce(order_number,'') order_number,
		coalesce(about_refund_payment, '') description,
		to_timestamp(date_time_refund, 'DD.MM.YYYY HH24:MI:SS')::timestamp operation_data,
		to_date(date_time_refund, 'DD.MM.YYYY HH24:MI:SS') processing_data,
		-refund_sum::decimal(18,2) operation_sum,
		0::decimal(18,2) commission,
		-refund_sum::decimal(18,2) to_transaction,
		sum(-refund_sum::decimal(18,2)) over (partition by file_key) bank_payment_sum,
		sum(-refund_sum::decimal(18,2)) over (partition by file_key) total_operation_sum,
		0::decimal(18,2) total_commision_sum,
		substring(recipient_name FROM '^[^ _]*') recipient_name
	from
        {{ source('banks', 'psb_acquiring_qr_refund') }} 
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
		payment_purpose = 'Возврат по операции C2B'	
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
	refund_aq aq left join bank_payments_for_refund	bp 
		on aq.processing_data = bp.date_transaction and aq.bank_payment_sum = bp.payment_sum and aq.recipient_name = bp.contragent
group by 
	aq.id_aq