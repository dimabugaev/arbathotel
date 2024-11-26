{{
  config(
	materialized = 'table',
	)
}}

with canceled_bookings as (
    select * from {{ ref('src_bookings') }} where status_id = 2
		and cancel_date >= 
        case 
            when extract(dow from now()) = 1 then -- Если сегодня понедельник
                (now() - interval '3 days')::date -- Берем пятницу
            else 
                (now() - interval '1 day')::date -- Иначе берем вчера
        end 
)
,bnovo_hotels as (
    select * from {{ ref('src_bnovo_hotels') }}
)
,booking_notes_array as (
    select booking_id::int as booking_id, array_agg(distinct description) comments
    from {{ source('bnovo', 'booking_notes') }}
    group by 
        1
)
,booking_create_users as (
    select distinct
        u.id, u.username, u.name, u.surname, b.booking_id::int as booking_id    
    from {{ source('bnovo', 'users') }} u join {{ source('bnovo', 'booking_users_link') }} b on u.id = b.user_id
)
,booking_cancel_reasons as (
    select distinct
        cr.name, b.booking_id::int as booking_id    
    from {{ source('bnovo', 'cancel_reasons') }} cr join {{ source('bnovo', 'booking_cancel_reason_link') }} b 
                                                    on cr.source_id = b.source_id and cr.id = b.cancel_reason_id
)
select
    cb.cancel_date,
    cb.arrival_date,
    cb.departure_date,
    bh.name hotel_name,
    bcu.name user_name,
    bcu.surname user_surname,
    cb.booking_number,
    'https://online.bnovo.ru/booking/general/' || cb.booking_id || '/?ref=booking' as booking_link,
    cb.contact_name guest_name,
    cb.contact_surname guest_surname,
    cb.contact_phone guest_phone,
    bcr.name cancel_reason,
    bna.comments
from canceled_bookings cb left join booking_notes_array bna on cb.booking_id = bna.booking_id
    left join booking_create_users bcu on cb.booking_id = bcu.booking_id
    left join booking_cancel_reasons bcr on cb.booking_id = bcr.booking_id
    left join bnovo_hotels bh on cb.hotel_id = bh.hotel_id
