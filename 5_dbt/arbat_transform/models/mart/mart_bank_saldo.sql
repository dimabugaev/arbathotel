{{
  config(
	materialized = 'table',
	)
}}

with report_period as (
select 
	min(mbp.date_transaction) date_from,
	max(mbp.date_transaction) date_to
from
    {{ ref('mart_bank_payments') }} mbp 
)
,saldo_as_is as (
	select 
		mbpp.source_id,
		mbpp.account_number,
		mbpp.source_name,
		mbpp.date_transaction,
		mbpp.total_debt
	from 
		(select 
			source_id,
			date_transaction, 
			max(sort_as_count_debt) num
		from 
			{{ ref('mart_bank_payments') }} mbp
		group by
			source_id,
			date_transaction) as saldo_point left join 
		{{ ref('mart_bank_payments') }} mbpp on saldo_point.source_id = mbpp.source_id 
			and saldo_point.date_transaction = mbpp.date_transaction
			and saldo_point.num = mbpp.sort_as_count_debt
)
,date_series as (
	SELECT generate_series(rp.date_from, rp.date_to, '1 day'::interval)::date AS day_in_period
	from report_period rp
)
,date_source_series as (
	select
		s.source_id,
		s.account_number,
		s.source_name,
		ds.day_in_period
	from 
		date_series ds left join 
		(select distinct source_id, account_number, source_name from saldo_as_is) s on true
)
,debt_by_date_series as (
	select
		ds.source_id,
		ds.account_number,
        ds.source_name,
		ds.day_in_period as date_transaction,
		saldo.total_debt
	from 
		date_source_series ds left join saldo_as_is saldo on ds.source_id = saldo.source_id and ds.day_in_period = saldo.date_transaction
)
select
	source_id,
	account_number,
	date_transaction,
    source_name,
	--total_debt,	
	first_value(total_debt) over(partition by source_id, gr order by date_transaction) total_debt
	from 
		(select 
			source_id
			,account_number
			,date_transaction
            ,source_name
			,total_debt
			,sum(case when total_debt is not null then 1 end) over (partition by source_id order by date_transaction) gr
		from 
			debt_by_date_series) t