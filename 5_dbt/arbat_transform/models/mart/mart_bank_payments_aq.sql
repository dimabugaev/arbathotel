{{
  config(
	materialized = 'table',
  indexes=[
      {
        'name': 'idx_ops_account_operation',
        'columns': ['source_id', 'id']
      }
    ]
	)
}}

select
    bp.source_id,
    bp.id,
    bp.id_aq,
    bp.account_number,
    bp.source_name,
    bp.type_id,
    bp.type_name,
    bp.date_transaction,
    bp.in_summ,
    bp.out_summ,
    bp.payment_purpose,
    bp.contragent_inn,
    bp.contragent,
    bp.contragent_account,
    bp.contragent_inner_name,
    bp.total_debt,
    bp.hotel_id,
    h.hotel_name hotel_name,
    bp.terminal_number,
    bp.order_number,
    bp.booking_id,
    bp.booking_number,
    bp.budget_item_id,
    bp.budget_item_perfix,
    bp.budget_item,
    bp.sort_as_count_debt
from {{ ref('calc_bank_payments_aq') }} bp left join {{ source('operate', 'hotels') }} h on bp.hotel_id = h.id