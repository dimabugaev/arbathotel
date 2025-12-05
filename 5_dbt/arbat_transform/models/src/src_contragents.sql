with contragents as (
    select * from {{ source('operate', 'contragents') }}
)
,budget_items as (
    select * from {{ source('operate', 'budget_items') }}
)
,filtered_contragents as (
    select
        co.id,
        co.contragent_name,
        co.inner_name,
        co.inn,
        co.account_number,
        co.income_budget_item_id,
        bi.item_name as income_budget_item_name,
        co.outcome_budget_item_id,
        bo.item_name as outcome_budget_item_name,
        co.hotel_id,
        row_number() over (partition by co.inn, co.account_number order by co.id) as row_number
    from contragents co left join budget_items bi on co.income_budget_item_id = bi.id 
    left join budget_items bo on co.outcome_budget_item_id = bo.id
    where trim(co.inn) <> '' and co.inn is not null) 
select * from filtered_contragents where row_number = 1
    