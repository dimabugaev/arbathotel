{{
  config(
	materialized = 'table',
	)
}}

with cards_info as
         (select
                 ca.id,
                 ca.card_source_id,
                 card_co.id   card_contragent_id,
                 ri.id report_item_id,
                 ca.report_source_id,
                 report_co.id report_contragent_id,
                 ca.start_date,
                 ca.end_date
          from {{ source('operate', 'card_assignments') }} ca
                   join {{ source('operate', 'contragents') }} card_co on ca.card_source_id = card_co.source_id
                   join {{ source('operate', 'contragents') }} report_co on ca.report_source_id = report_co.source_id
                   join {{ source('operate', 'report_items') }} ri on card_co.id = ri.contragent_id)
,new_source_auto_rows as
    (select
        ci.report_source_id source_id,
        bp.id outer_row_business_id,
        ci.report_item_id,
        bp.date_transaction report_date,
        0 sum_income,
        bp.out_summ sum_spend,
        '' string_comment
    from {{ ref('mart_bank_payments_aq') }} bp
    join cards_info ci on
        bp.source_id = ci.card_source_id
            and bp.date_transaction >= ci.start_date
            and (bp.date_transaction <= ci.end_date or ci.end_date is null)
            and bp.out_summ <> 0)
select
    rs.id id,
    all_new_row.source_id source_id,
    all_new_row.report_item_id,
    coalesce(rs.created, CURRENT_TIMESTAMP) created,
    rs.applyed applyed,
    all_new_row.report_date report_date,
    rs.hotel_id hotel_id,
    all_new_row.sum_income sum_income,
    all_new_row.sum_spend sum_spend,
    coalesce(rs.string_comment, all_new_row.string_comment) string_comment,
    null parent_row_id,
    all_new_row.outer_row_business_id
from new_source_auto_rows all_new_row left join {{ source('operate', 'report_strings') }} rs
    on all_new_row.source_id = rs.source_id
    and all_new_row.outer_row_business_id = rs.outer_row_business_id