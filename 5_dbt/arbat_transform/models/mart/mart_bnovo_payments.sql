{{
  config(
	materialized = 'table',
    indexes=[
      {'columns': ['payment_id']},
      {'columns': ['paid_date']},
    ]
	)
}}

with src_bnovo_payments as (
    select * from {{ ref('src_bnovo_payments') }}
),
raw_suppliers as (
    select * from {{ source('bnovo', 'suppliers') }}
),
src_bookings as (
    select * from {{ ref('src_bookings') }}
),
bnovo_payments_type as (
    select * from {{ ref('seed_bnovo_payments_type_id') }} 
),
bnovo_hotels as (
    select * from {{ ref('src_bnovo_hotels') }}
)
select
    p.source_id,
    p.source_name,
    p.payment_id,
    p.supplier_id supplier_id,
    s.name supplier_name,
    p.hotel_id hotel_id,
    h.name hotel_name,
    p.paid_date paid_date,
    p.create_date create_date,
    p.in_summ in_summ,
    p.out_summ out_summ,
    p.total_debt total_debt,
    p.booking_id booking_id,
    b.booking_number booking_number,
    b.plan_arrival_date plan_arrival_date,
    b.plan_departure_date plan_departure_date,
    p.item_id,
    p.item_name,
    p.reason reason,
    p.type_id type_id,
    pt.type_name payment_type,
    p.payer_name payer_name,
    p.user_id,
    p.user_name,
    case
        when p.booking_id = 0 then
            ''
        else
            'https://online.bnovo.ru/booking/general/' || p.booking_id || '/?ref=booking'
    end as booking_link,
    ROW_NUMBER() OVER (ORDER BY p.source_id, p.paid_date, bp.payment_id) as sort_as_count_debt
from
    src_bnovo_payments p left join bnovo_hotels h on p.hotel_id = h.hotel_id
    left join src_bookings b on p.booking_id = b.booking_id 
    left join raw_suppliers s on p.supplier_id = s.id
    left join bnovo_payments_type pt on p.type_id = pt.type_id