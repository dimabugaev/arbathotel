{{
  config(
	materialized = 'table',
	)
}}

with banks_payments as (
    select
        source_id,
        id::text,
        '' id_aq,
        account_number,
        source_type,
        source_name,
        date_transaction,
        in_summ,
        out_summ,
        payment_purpose,
        contragent_inn,
        contragent,
        total_debt,
        null hotel_id,
        '' hotel_name,
        null terminal_number,
        null order_number,
        null booking_id,
        null booking_number
    from
        {{ ref('src_bank_tinkoff_payments') }}
    
    union all

    select
        source_id,
        id::text,
        id_aq,
        account_number,
        source_type,
        source_name,
        date_transaction,
        in_summ,
        out_summ,
        payment_purpose,
        contragent_inn,
        contragent,
        total_debt,
        hotel_id,
        hotel_name,
        terminal_number,
        order_number,
        booking_id,
        booking_number
    from
        {{ ref('calc_psb_payments_with_aq') }}

    union all

    select
        source_id,
        id::text,
        '',
        account_number,
        source_type,
        source_name,
        date_transaction,
        in_summ,
        out_summ,
        payment_purpose,
        contragent_inn,
        contragent,
        total_debt,
        null hotel_id,
        '' hotel_name,
        null terminal_number,
        null order_number,
        null booking_id,
        null booking_number
    from
        {{ ref('src_bank_alfa_payments') }}
)
,hotel_syn as (
    select 
        t1.id AS hotel_id,
        t1.hotel_name,
        trim(synonym) AS synonym
    from {{ source('operate', 'hotels') }} t1,
        LATERAL unnest(string_to_array(t1.synonyms, ',')) AS synonym
)
,out_payment_hotel_info as (
    select
        t1.source_id,
        t1.id,
        t1.id_aq,
        t1.hotel_id,
        t2.hotel_name
    from 
        (select
            bp.source_id,
            bp.id,
            bp.id_aq,
            min(hs.hotel_id) hotel_id
        from 
            banks_payments bp join hotel_syn hs on bp.payment_purpose like '%' || hs.synonym || '%'
        where
            bp.hotel_id is null and bp.out_summ <> 0 and bp.id_aq = ''
        group by
            bp.source_id,
            bp.id,
            bp.id_aq) as t1 join {{ source('operate', 'hotels') }} t2 on t1.hotel_id = t2.id    
)
,bnovo_bank_invoices as (
    select distinct
        source_id,
        cyrillic_invoice_number,
        booking_id
    from
        {{ ref('src_bnovo_invoices_for_bank') }}
)
,booking_data_ordinary_in_payment as (
    select
        bp.source_id,
        bp.id,
        bp.id_aq,
        min(bi.booking_id) booking_id
    from 
        (
            select
                source_id,
                id,
                id_aq,
                unnest(regexp_matches(payment_purpose, '[а-яА-Яa-zA-Z]{2,3}-\d+', 'g')) as key_invoice 
            from banks_payments
            where
                hotel_id is null and in_summ <> 0 and id_aq = ''
        ) bp join bnovo_bank_invoices bi 
            on bi.cyrillic_invoice_number = {{ convert_to_cyrillic('upper(bp.key_invoice)') }}
                and bi.source_id = bp.source_id
    group by
        bp.source_id,
        bp.id,
        bp.id_aq
)
,ordinar_in_payment_hotel_info as (
    select distinct
        t1.source_id,
        t1.id,
        t1.id_aq,
        t1.booking_id,
        t2.booking_number,
        t2.hotel_id,
        t3.hotel_name
    from 
        booking_data_ordinary_in_payment as t1 
        join {{ ref('src_bookings') }} t2 on t1.booking_id = t2.booking_id    
        join {{ source('operate', 'hotels') }} t3 on t2.hotel_id = t3.id    
)
select
    bp.source_id,
    bp.id,
    bp.id_aq,
    bp.account_number,
    bp.source_name,
    st.type_id,
    st.type_name,
    bp.date_transaction,
    bp.in_summ,
    bp.out_summ,
    bp.payment_purpose,
    bp.contragent_inn,
    bp.contragent,
    bp.total_debt,
    coalesce(hi2.hotel_id, hi.hotel_id, bp.hotel_id) hotel_id,
    coalesce(hi2.hotel_name, hi.hotel_name, bp.hotel_name) hotel_name,
    bp.terminal_number,
    bp.order_number,
    coalesce(hi2.booking_id, bp.booking_id) booking_id,
    coalesce(hi2.booking_id, bp.booking_number) booking_number,
    ROW_NUMBER() OVER (ORDER BY bp.source_id, bp.date_transaction, bp.id, bp.id_aq, bp.out_summ) as sort_as_count_debt
from
   banks_payments bp join {{ ref('seed_sources_type_id') }} st
   on bp.source_type = st.type_id 
   left join out_payment_hotel_info hi on bp.source_id = hi.source_id and bp.id = hi.id and bp.id_aq = hi.id_aq
   left join ordinar_in_payment_hotel_info hi2 on bp.source_id = hi2.source_id and bp.id = hi2.id and bp.id_aq = hi2.id_aq