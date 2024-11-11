with qr_aq as (
	select
		aq.rpn id_aq,
		aq.operation_type,
		aq.file_key,
		aq.device_number::int terminal_number,
		aq.device_name,
		coalesce(aq.order_number,'') order_number,
		coalesce(aq.description, '') description,
		to_timestamp(aq.operation_data, 'DD.MM.YYYY HH24:MI:SS')::timestamp operation_data,
		to_date(aq.processing_data, 'DD.MM.YYYY') processing_data,
		aq.operation_sum::decimal(18,2) operation_sum,
		aq.commission::decimal(18,2) commission,
		aq.to_transaction::decimal(18,2) to_transaction,
		coalesce(d.source_id, iaq.source_id) source_id,
		coalesce(d.hotel_id, iaq.hotel_id) hotel_id,
		coalesce(iaq.booking_id, '') booking_id,
		coalesce(iaq.booking_number, '') booking_number,
		sum(aq.to_transaction::decimal(18,2)) over (partition by aq.file_key) bank_payment_sum,
		sum(aq.operation_sum::decimal(18,2)) over (partition by aq.file_key) total_operation_sum,
		sum(aq.commission::decimal(18,2)) over (partition by aq.file_key) total_commision_sum
	from 
        {{ source('banks', 'psb_acquiring_term') }} aq left join {{ source('operate', 'devices') }} d on aq.device_number::int = d.id
		left join {{ ref('calc_bookings_hotels_for_internet_aq') }} iaq on aq.order_number = iaq.order_number
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
	max(aq.source_id) source_id,
	max(aq.hotel_id) hotel_id,
	max(aq.booking_id) booking_id,
	max(aq.booking_number) booking_number,
	max(bp.id) bank_payment_id,
	max(bp.payment_purpose) bank_payment_purpose
from
	qr_aq aq left join bank_payments_for_refund	bp 
		on aq.processing_data = bp.date_transaction and aq.bank_payment_sum = bp.payment_sum 
		and (aq.source_id = bp.source_id or aq.order_number is not null)
group by
	aq.file_key,
	aq.id_aq,
	aq.operation_type