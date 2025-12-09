with psb_strings as (
    select * from {{ source('banks', 'psb_docs_rows') }}
)
,aq_qr_refund as (
    select * from {{ ref('src_psb_acquiring_qr_refund') }}
)
,aq_qr as (
    select * from {{ ref('src_psb_acquiring_qr') }}
)
,aq_term as (
    select * from {{ ref('src_psb_acquiring_term') }}
)
,aq_all as (
    select
        id_aq,  
        operation_type,
        terminal_number,
        order_number,
        description,
        operation_data,
        false debit, 
        operation_sum summa_rur,
        bank_payment_id,
        source_id,
        hotel_id,
        booking_id,
        booking_number,
        case 
            when order_number is not null and order_number <> '' then
                6
            else 
                5
        end as budget_item_id,
        case 
            when order_number is not null and order_number <> '' then
                'Он-лайн оплата'
            else 
                'Карты'
        end as budget_item
    from 
       aq_term
    union all
    select
        id_aq,  
        operation_type,
        terminal_number,
        order_number,
        description,
        operation_data,
        true debit, 
        commission summa_rur,
        bank_payment_id,
        source_id,
        hotel_id,
        booking_id,
        booking_number,
        case 
            when order_number is not null and order_number <> '' then
                132
            else 
                61
        end as budget_item_id,
        case 
            when order_number is not null and order_number <> '' then
                'Интернет-эквайринг'
            else 
                'Комиссия по картам'
        end as budget_item
    from 
       aq_term 
    union all
    select
        id_aq,  
        'payment_qr' operation_type,
        terminal_number,
        order_number,
        description,
        operation_data,
        false debit, 
        operation_sum summa_rur,
        bank_payment_id,
        source_id,
        hotel_id,
        null,
        null,
        5,
        'Карты'
    from 
       aq_qr
    union all
    select
        id_aq,  
        'commision_qr',
        terminal_number,
        order_number,
        description,
        operation_data,
        true debit, 
        commission summa_rur,
        bank_payment_id,
        source_id,
        hotel_id,
        null,
        null,
        61,
        'Комиссия по картам'
    from 
       aq_qr
    union all
    select
        id_aq,  
        'refund_qr' operation_type,
        terminal_number,
        order_number,
        description,
        operation_data,
        false debit, 
        operation_sum summa_rur,
        bank_payment_id,
        source_id,
        hotel_id,
        null,
        null,
        null,
        null
    from 
       aq_qr_refund 
)
,distrib_payments as (
    select
        pdr.doc_id,
        aq.id_aq,
        pdr.source_id,
        pdr.row_date,
        coalesce(aq.debit, pdr.debit) debit,
        pdr.outer_account,
        case 
            when pdr.outer_account = '' or pdr.outer_account is null then
                pdr.account
            else
                pdr.outer_account
        end as contragent_account,
        pdr.kb,
        pdr.contragent_inn,
        pdr.contragent,
        pdr.description,
        coalesce(aq.summa_rur, pdr.summa_rur) summa_rur,
        aq.terminal_number,
        aq.order_number,
        aq.hotel_id,
        aq.booking_id,
        aq.booking_number,
        aq.budget_item_id,
        aq.budget_item 
    from
        psb_strings pdr left join aq_all aq on pdr.doc_id = aq.bank_payment_id and (pdr.source_id = aq.source_id  or (order_number is not null and order_number <> ''))  
)
select
	pdr.doc_id id,
	pdr.source_id,
    coalesce(pdr.id_aq, '') id_aq,
    pdr.booking_id,
    pdr.booking_number,
    pdr.hotel_id,
    pdr.budget_item_id,
    pdr.budget_item,
    h.hotel_name,
	s.source_external_key as account_number,
	s.source_type, -- bank internal code
    s.source_name,
	pdr.row_date date_doc,
	pdr.row_date date_transaction,
	not pdr.debit as income,
	pdr.contragent_account as contragent_account,
	pdr.kb as contragent_bic,
	'' contragent_bank,
	pdr.contragent_inn as contragent_inn,
	pdr.contragent as contragent,
	pdr.description as payment_purpose,
	pdr.summa_rur amount,
	case 
		when pdr.debit then -- расход
			pdr.summa_rur
		else -- приход
			0	
	end as out_summ,
	case 
		when pdr.debit then -- расход
			0
		else -- приход
			pdr.summa_rur	
	end as in_summ,
	pdr.terminal_number,
	pdr.order_number,
	SUM(case 
		when pdr.debit then -- расход
			0
		else -- приход
			pdr.summa_rur	
	end - case 
		when pdr.debit then -- расход
			pdr.summa_rur
		else -- приход
			0	
	end) OVER (partition by pdr.source_id ORDER BY pdr.row_date, pdr.doc_id, pdr.id_aq, pdr.debit) + COALESCE(s.source_income_debt,0) AS total_debt
from 
	distrib_payments pdr join
	{{ ref('src_sources') }} s on pdr.source_id = s.source_id
    left join {{ source('operate', 'hotels') }} h on pdr.hotel_id = h.id