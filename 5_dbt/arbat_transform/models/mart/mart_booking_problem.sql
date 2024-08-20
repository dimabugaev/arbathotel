{{
  config(
	materialized = 'table',
	)
}}

with selected_bookings as(
	select 
		*
	from
		{{ ref('src_bookings') }} 
	where
		plan_arrival_date::date <= now()::date 
		and plan_departure_date::date >= (now() - interval '1 DAY')::date
		and (status_id = 3 or status_id = 4)   -- Заселен Выехал
		and plan_departure_date::date - plan_arrival_date::date > 1
),
one_days_booking_guests as (
	select 
		sb.booking_id,
		sb.plan_arrival_date::date as arrival_date, 
		sb.plan_departure_date::date - sb.plan_arrival_date::date,
		sbg.id as guest_id
	from
		public.src_bookings sb inner join public.src_booking_guests sbg on sb.booking_id = sbg.booking_id 
	where
		sb.plan_arrival_date::date <= now()::date 
		and sb.plan_departure_date::date >= (now() - interval '1 DAY')::date
		and (sb.status_id = 3 or sb.status_id = 4)
		and sb.plan_departure_date::date - sb.plan_arrival_date::date = 1
),
divergence_guests_amount as (
	select 
		sb.booking_id,
		max(sb.adults) + max(sb.children) as guest_in_number,
		sum(case 
				when sbg.booking_id is not null then 1 
				else 0 
  			end) as guest_added
	from 
		selected_bookings sb left join {{ ref('src_booking_guests') }} as sbg 
			on sb.booking_id = sbg.booking_id
	group by 
		sb.booking_id
	having 
		max(sb.adults) + max(sb.children) <> sum(case 
													when sbg.booking_id is not null then 1 
													else 0 
												end)	
),
no_canceled as (
	select 
		booking_id
	from
		{{ ref('src_bookings') }} 
	where
		plan_arrival_date::date <= (now() - interval '1 DAY')::date 
		and status_id = 1		
),
no_applyed as (
	select distinct
		sb.booking_id
	from 
		selected_bookings sb inner join {{ ref('src_booking_guests') }} as sbg 
			on sb.booking_id = sbg.booking_id
		inner join {{ source('bnovo', 'temp_no_applyed_guests') }} as nap 
			on sbg.id = nap.guest_id::int	
),
no_guests_data as (
	select 
		sb.booking_id
	from 
		selected_bookings sb left join {{ ref('src_booking_guests') }} as sbg 
			on sb.booking_id = sbg.booking_id
	where 
		sbg.citizenship_id is null or sbg.citizenship_id = 0
		or sbg.citizenship_name is null or trim(sbg.citizenship_name) = '' 
		or sbg.name is null or trim(sbg.name) = ''
		or sbg.surname is null or trim(sbg.surname) = ''
		or sbg.birthdate is null
		or sbg.document_type is null or sbg.document_type = 0
		or sbg.document_series is null or trim(sbg.document_series) = ''
		or sbg.document_number is null or trim(sbg.document_number) = ''
),
select_changed as(
	select
		sb.booking_id,
		case 
			when count(distinct sb.adults) > 1 or count(distinct sb.children) > 1 then
				true
			else
				false
		end as amount_of_guest_changed,
		case 
			when count(distinct sb.plan_departure_date) > 1 then 
				true 
			else 
				false
		end as departure_date_changed
	from
		{{ ref('snp_bookings') }} sb inner join selected_bookings sel_b 
			on sb.booking_id = sel_b.booking_id and sb.status_id = sel_b.status_id
	group by
		sb.booking_id
	having 
		count(distinct sb.adults) > 1 or count(distinct sb.children) > 1 or count(distinct sb.plan_departure_date) > 1	
),
guests_changed as(
	select 
		count_delta.booking_id,
		sum(count_delta.delta_guests) as delta_guests
	from (
		select 
			sb.booking_id,
			sb.adults + sb.children - (lead(sb.adults) over id_win + lead(sb.children) over id_win) as delta_guests
		from
			{{ ref('snp_bookings') }} sb inner join select_changed sc 
				on sb.booking_id = sc.booking_id and sc.amount_of_guest_changed and (sb.status_id = 3 or sb.status_id = 4)
		window id_win as (partition by sb.booking_id order by sb.updated_at desc) 
	) count_delta
	group by 
		booking_id		
),
departure_changed as(
	select 
		count_delta.booking_id,
		sum(count_delta.delta_departure_date) as delta_departure_date
	from (
		select 
			sb.booking_id,
			(extract(epoch from sb.plan_departure_date) - extract(epoch from lead(sb.plan_departure_date) over id_win))/86400 as delta_departure_date
		from
			{{ ref('snp_bookings') }} sb inner join select_changed sc 
				on sb.booking_id = sc.booking_id and sc.departure_date_changed and (sb.status_id = 3 or sb.status_id = 4)
		window id_win as (partition by sb.booking_id order by sb.updated_at desc) 
	) count_delta
	group by 
		booking_id
),
one_day_continue_booking as(
	select distinct 
		odb.booking_id
	from
		public.src_bookings sb inner join public.src_booking_guests sbg on sb.booking_id = sbg.booking_id
			inner join one_days_booking_guests odb on odb.guest_id = sbg.id and sb.real_departure::date = odb.arrival_date
),
err_satuses as(
	select 
		booking_id,
		1 as err_status_id,
		'Расхождение гостей' as err_status_name
	from 
		divergence_guests_amount
	
	union all
	
	select 
		booking_id,
		2 as err_status_id,
		'Не отмененные' as err_status_name
	from 
		no_canceled
		
	union all
	
	select 
		booking_id,
		3 as err_status_id,
		'Нет данных гостей' as err_status_name
	from 
		no_guests_data
	
	union all
	
	select 
		booking_id,
		case 
			when delta_guests > 0 then
				4
			else
				5
		end as err_status_id,
		case 
			when delta_guests > 0 then
				'Увеличение гостей'
			else
				'Уменьшение гостей'
		end as err_status_name
	from 
		guests_changed
	
	union all
	
	select 
		booking_id,
		case 
			when delta_departure_date > 0 then
				6
			else
				7
		end as err_status_id,
		case 
			when delta_departure_date > 0 then
				'Продление проживания'
			else
				'Уменьшение проживания'
		end as err_status_name
	from 
		departure_changed

	union all
	
	select 
		booking_id,
		8 as err_status_id,
		'Не подан' as err_status_name
	from 
		no_applyed

	union all
	
	select 
		booking_id,
		9 as err_status_id,
		'Однодневное продление' as err_status_name
	from 
		one_day_continue_booking
)
select
	sbh.hotel_id,
	sbh.name as hotel,
	sb.booking_id,
	sb.booking_number,
	'https://online.bnovo.ru/booking/general/' || sb.booking_id || '/?ref=booking' as booking_link,
	sb.status_id,
	sb.status_name,
	sb.plan_arrival_date::date,
	sb.plan_departure_date::date,
	sb.adults,
	sb.children,
	err.err_status_id,
	err.err_status_name,
	sb.updated_at,
	bg.id as guest_id,
	bg.name,
	bg.surname,
	bg.citizenship_name,
	bg.birthdate,
	bg.address_free,
	'https://online.bnovo.ru/booking/guests/' || sb.booking_id || '/#' as guests_link
from 
	err_satuses err inner join {{ ref('src_bookings') }} sb on err.booking_id = sb.booking_id
	inner join {{ ref('src_bnovo_hotels') }} sbh on sb.hotel_id = sbh.hotel_id
	left join {{ ref('src_booking_guests') }} bg on sb.booking_id = bg.booking_id