{{ config(
    materialized='table'
) }}

with report_period as (select 
	current_date date_to,
	(date_trunc('month', current_date) - INTERVAL '1 month')::date date_from)
select
	source_id,
    period_month,
    id::int id,
    supplier_id::int supplier_id,
    nullif(contractor_id, '0')::int contractor_id,
    external_hotel_id::int external_hotel_id,
    external_booking_id::int external_booking_id,
    external_user_id::int external_user_id,
    external_user_name,
    external_payment_id,
    external_supplier_id,
    passport,
    name,
    type_id,
    item_id,
    amount::decimal(18,2) amount,
    balance,
    paid_date,
    reason,
    create_date,
    fiscal_status,
    sub_amount::decimal(18,2) sub_amount,
    id_command,
    date_update
from 
	{{ source('bnovo', 'payments') }}
where 
	period_month >= (select date_from from report_period)
	and period_month <= (select date_to from report_period)
	and external_booking_id <> '0'