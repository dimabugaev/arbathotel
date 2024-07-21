{{
  config(
	materialized = 'table',
	)
}}

with banks_payments as (
    select
        source_id,
        id::text,
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
        null terminal_number,
        null order_number
    from
        {{ ref('src_bank_tinkoff_payments') }}
    
    union all

    select
        source_id,
        id::text,
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
        terminal_number,
        order_number
    from
        {{ ref('calc_psb_payments_with_aq') }}

    union all

    select
        source_id,
        id::text,
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
        null terminal_number,
        null order_number
    from
        {{ ref('src_bank_alfa_payments') }}
)
select
    bp.source_id,
    bp.id,
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
    terminal_number,
    order_number,
    ROW_NUMBER() OVER (ORDER BY bp.source_id, bp.date_transaction, bp.id) as sort_as_count_debt
from
   banks_payments bp join {{ ref('seed_sources_type_id') }} st
   on bp.source_type = st.type_id