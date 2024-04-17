with tinkoff_payments as (
    select
        *
    from {{ source('banks', 'tinkoff_payments') }}
)
select
	tp.id,
	tp.source_id,
	s.source_external_key as account_number,
	s.source_type, -- bank internal code
    s.source_name,
	to_date(tp.date, 'YYYY-MM-DD') date_doc,
	to_date(tp.draw_date, 'YYYY-MM-DD') date_transaction,
	case 
		when s.source_external_key = tp.payer_account then -- расход
			false
		else -- приход
			true	
	end as income,
	case 
		when s.source_external_key = tp.payer_account then
			tp.recipient_account
		else
			tp.payer_account
	end as contragent_account,
	case 
		when s.source_external_key = tp.payer_account then
			tp.recipient_bic
		else
			tp.payer_bic
	end as contragent_bic,
	case 
		when s.source_external_key = tp.payer_account then
			tp.recipient_bank
		else
			tp.payer_bank
	end as contragent_bank,
	case 
		when s.source_external_key = tp.payer_account then
			tp.recipient_inn
		else
			tp.payer_inn
	end as contragent_inn,
	case 
		when s.source_external_key = tp.payer_account then
			tp.recipient
		else
			tp.payer_name
	end as contragent,
	tp.payment_purpose,
	tp.amount::decimal(18,2) amount,
	case 
		when s.source_external_key = tp.payer_account then -- расход
			tp.amount::decimal(18,2)
		else -- приход
			0	
	end as out_summ,
	case 
		when s.source_external_key = tp.payer_account then -- расход
			0
		else -- приход
			tp.amount::decimal(18,2)	
	end as in_summ,
	SUM(case 
		when s.source_external_key = tp.payer_account then -- расход
			0
		else -- приход
			tp.amount::decimal(18,2)	
	end - case 
		when s.source_external_key = tp.payer_account then -- расход
			tp.amount::decimal(18,2)
		else -- приход
			0	
	end) OVER (partition by tp.source_id ORDER BY to_date(tp.draw_date, 'YYYY-MM-DD'), tp.id) + COALESCE(s.source_income_debt,0) AS total_debt
from 
	tinkoff_payments tp join
	{{ ref('src_sources') }} s on tp.source_id = s.source_id