{{
  config(
	materialized = 'table',
	)
}}
with raw_payments as (
    select * from {{ source('bnovo', 'payments') }}
)
select
    p.source_id,
    s.source_name,
    p.id::int as payment_id,
    p.external_hotel_id::int as hotel_id,
    p.external_booking_id::int as booking_id,
    p.external_user_id::int as user_id,
    p.external_user_name as user_name,
    p.external_supplier_id as supplier_id,
    p.name as payer_name,
    p.type_id::int as type_id,
    p.amount::decimal(18,2) as sum_payment,
    p.paid_date::timestamp as paid_date,
    p.create_date::timestamp as create_date,
    p.reason as reason,
    case 
		when p.amount::decimal(18,2) < 0 then -- расход
			- p.amount::decimal(18,2)
		else -- приход
			0	
	end as out_summ,
	case 
		when p.amount::decimal(18,2) > 0 then -- приход
			p.amount::decimal(18,2)
		else -- расход
			0	
	end as in_summ,
	SUM(case 
            when p.type_id::int = 2 then -- нал
                p.amount::decimal(18,2)
            else
                0	
	    end) OVER (partition by p.source_id ORDER BY p.paid_date, p.id) + COALESCE(s.source_income_debt,0) AS total_debt
from 
    raw_payments p join
	{{ ref('src_sources') }} s on p.source_id = s.source_id