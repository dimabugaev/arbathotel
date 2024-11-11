with payment_data as (
select distinct
	id,
	false refund,
	cart,
	jsonb_array_elements(cart) cart_detail
from 
    {{ source('banks', 'paykeeper_payments') }}
where
	cart is not null
union all 		
select distinct
	id,
	true refund,
	refund_1_cart,
	jsonb_array_elements(refund_1_cart) cart_detail
from 
	{{ source('banks', 'paykeeper_payments') }}
where
	refund_1_cart is not null
)	
,excract_booking_number as (
select 
	id,
	refund,
	cart,
	--cart_detail ->> 'name',
	cart_detail,
	(cart_detail ->> 'sum')::numeric cart_sum,
	case
		when STRPOS(regexp_replace(cart_detail ->> 'name', '^.*([A-Z0-9]{5}[-_][0-9]{6}).*$', '\1'),'_') > 0 then
			true
		else
			false
	end changed, 
	trim(regexp_replace(cart_detail ->> 'name', '^.*([A-Z0-9]{5}[-_][0-9]{6}).*$', '\1')) AS booking_number
from 
	payment_data)
,joined_paiments_result as (
select
	ebn.id as order_number,
	max(sb.booking_id) booking_id
from 
	excract_booking_number ebn left join {{ ref('src_bookings') }} sb on (ebn.booking_number = sb.main_booking_number or ebn.booking_number = sb.booking_number)
where 
	sb.booking_id is not null
group by
	order_number)
select distinct 
	pr.order_number,
	pr.booking_id,
	sb.booking_number,
    sb.source_id,
	h.id hotel_id,
	h.hotel_name 
from 
	joined_paiments_result pr join {{ ref('src_bookings') }} sb on (pr.booking_id = sb.booking_id) join {{ source('operate', 'hotels') }} h on (sb.hotel_id::text = h.bnovo_id)