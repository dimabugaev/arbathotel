{{
  config(
	materialized = 'table',
	)
}}

with report_period as (
select 
	min(mbp.paid_date) date_from,
	max(mbp.paid_date) date_to
from
    {{ ref('mart_bnovo_payments') }} mbp 
where 
	mbp.type_id = 2 --cash
)
,max_dates_of_paymants_days as (
	select 
		source_id,
		date(paid_date) paid_day, 
		max(paid_date) last_payment_date
	from 
		{{ ref('mart_bnovo_payments') }}
	where 
		type_id = 2 --cash	
	group by
		source_id,
		date(paid_date)	
)
,max_ids_of_paymant_days as (
	select 
		mbp.source_id,
		mdp.paid_day,
		--mbp.paid_date, 
		max(mbp.payment_id) last_id
	from 
		{{ ref('mart_bnovo_payments') }} mbp join max_dates_of_paymants_days mdp 
			on mbp.source_id = mdp.source_id and mbp.paid_date = mdp.last_payment_date
	where 
		mbp.type_id = 2 --cash	
	group by
		mbp.source_id,
		mdp.paid_day			
)
,saldo_as_is as (
	select 
		mbpp.source_id,
		mbpp.hotel_name,
		mbpp.source_name,
		max_id.paid_day,
		mbpp.total_debt
	from 
		{{ ref('mart_bnovo_payments') }} mbpp join max_ids_of_paymant_days max_id on max_id.source_id = mbpp.source_id 
			and max_id.last_id = mbpp.payment_id
)
,date_series as (
	SELECT generate_series(rp.date_from, rp.date_to, '1 day'::interval)::date AS day_in_period
	from report_period rp
)
,date_source_series as (
	select
		s.source_id,
		s.hotel_name,
		s.source_name,
		ds.day_in_period
	from 
		date_series ds left join 
		(select distinct source_id, hotel_name, source_name from saldo_as_is) s on true
)
,debt_by_date_series as (
	select
		ds.source_id,
		ds.hotel_name,
        ds.source_name,
		ds.day_in_period as paid_date,
		saldo.total_debt
	from 
		date_source_series ds left join saldo_as_is saldo on ds.source_id = saldo.source_id and ds.day_in_period = saldo.paid_day
)
select
	source_id,
	hotel_name,
	paid_date,
    source_name,
	--total_debt,	
	first_value(total_debt) over(partition by source_id, gr order by paid_date) total_debt
	from 
		(select 
			source_id
			,hotel_name
			,paid_date
            ,source_name
			,total_debt
			,sum(case when total_debt is not null then 1 end) over (partition by source_id order by paid_date) gr
		from 
			debt_by_date_series) t