with payments as (
	select 
		source_id,
		period_month,
		external_booking_id booking_id,
		sum(amount) payed_current_period
	from 
		{{ ref('src_bnovo_payments_last_two_month') }}
	group by
		source_id, period_month, external_booking_id
		)
select 
	p.source_id,
	p.period_month,
	u.id user_id,
	u.name username,
	u.surname usersurname,
	h.hotel_name,
	b.booking_number,
	b.created_at,
	b.status_name,
	b.contact_name,
	b.contact_surname,
	b.plan_arrival_date,
	b.plan_departure_date,
	p.payed_current_period,
	b.prices_services_total,
	b.prices_rooms_total,
	b.provided_total,
	b.payments_total,
	'https://online.bnovo.ru/booking/general/' || b.booking_id || '/?ref=booking' as booking_link
from 
	payments p join {{ ref('src_bookings') }} b on p.source_id = b.source_id and p.booking_id = b.booking_id
	join {{ source('operate', 'hotels') }} h on b.hotel_id::text = h.bnovo_id
	left join {{ source('bnovo', 'users') }} u on b.source_id = u.source_id and b.user_id = u.id