{{
  config(
	materialized = 'table',
	)
}}

select
    source_id,
    id,
    id_aq,
    account_number,
    source_name,
    type_id,
    type_name,
    date_transaction,
    in_summ,
    out_summ,
    payment_purpose,
    contragent_inn,
    contragent,
    contragent_account,
    contragent_inner_name,
    total_debt,
    hotel_id hotel_id,
    hotel_name hotel_name,
    terminal_number,
    order_number,
    booking_id,
    booking_number,
    budget_item_id,
    budget_item_perfix,
    budget_item,
    sort_as_count_debt
from {{ ref('calc_bank_payments_aq') }}