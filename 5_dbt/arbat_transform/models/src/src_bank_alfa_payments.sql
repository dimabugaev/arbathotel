with alfa_payments as (
    select * from {{ source('banks', 'alfa_payments') }}
)
select
	ap.id,
	ap.source_id,
	s.source_external_key as account_number,
	s.source_type, -- bank internal code
	to_date(ap.document_date, 'YYYY-MM-DD') date_doc,
	(ap.operation_date::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Moscow')::date AS date_transaction,
	case 
		when s.source_external_key = ap.rur_payer_account then -- расход
			false
		else -- приход
			true	
	end as income,
	case 
		when s.source_external_key = ap.rur_payer_account then
			ap.rur_payee_account
		else
			ap.rur_payer_account
	end as contragent_account,
	case 
		when s.source_external_key = ap.rur_payer_account then
			ap.rur_payee_bank_bic
		else
			ap.rur_payer_bank_bic
	end as contragent_bic,
	case 
		when s.source_external_key = ap.rur_payer_account then
			ap.rur_payee_bank_name
		else
			ap.rur_payer_bank_name
	end as contragent_bank,
	case 
		when s.source_external_key = ap.rur_payer_account then
			ap.rur_payee_inn
		else
			ap.rur_payer_inn
	end as contragent_inn,
	case 
		when s.source_external_key = ap.rur_payer_account then
			ap.rur_payee_name
		else
			ap.rur_payer_name
	end as contragent,
	ap.payment_purpose,
	ap.amount_rub_amount::decimal(18,2) amount,
	case 
		when s.source_external_key = ap.rur_payer_account then -- расход
			ap.amount_rub_amount::decimal(18,2)
		else -- приход
			0	
	end as out_summ,
	case 
		when s.source_external_key = ap.rur_payer_account then -- расход
			0
		else -- приход
			ap.amount_rub_amount::decimal(18,2)	
	end as in_summ,
	SUM(case 
		when s.source_external_key = ap.rur_payer_account then -- расход
			0
		else -- приход
			ap.amount_rub_amount::decimal(18,2)	
	end - case 
		when s.source_external_key = ap.rur_payer_account then -- расход
			ap.amount_rub_amount::decimal(18,2)
		else -- приход
			0	
	end) OVER (partition by ap.source_id ORDER BY (ap.operation_date::timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'Europe/Moscow')::date, ap.id) + COALESCE(s.source_income_debt,0) AS total_debt		
from 
	alfa_payments ap join
	{{ ref('src_sources') }} s on ap.source_id = s.id