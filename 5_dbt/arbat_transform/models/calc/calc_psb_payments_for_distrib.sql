with psb_payments as (
    select * from {{ ref('src_psb_payments') }}
    where not debit
),
bank_invoices as (
    select *
    from
        {{ ref('src_bnovo_invoices_for_bank') }}
),
psb_raw_keys as (
    select
        psb_payments.source_id,
        psb_payments.payment_key,
        psb_payments.payment_id,
        psb_payments.number_doc,
        psb_payments.account,
        --unnest(regexp_matches(psb_payments.remark, '[а-яА-Яa-zA-Z]{2}-\d{3,4}', 'g')) as key_invoice,
        unnest(regexp_matches(psb_payments.remark, '[а-яА-Яa-zA-Z]{2,3}-\d+', 'g')) as key_invoice,
        psb_payments.remark,
        psb_payments.summa_rur,
        psb_payments.created_at
    from psb_payments
),
temp_distrib as (
    select distinct
        bi.source_id,  -- we take source from bnovo invoices
        bi.supplier_id,
        bi.hotel_supplier_id,  
        pk.payment_key,
        pk.payment_id,
        pk.number_doc,
        pk.account,
        pk.summa_rur,
        pk.created_at,
        {{ convert_to_cyrillic('upper(pk.key_invoice)') }} as cyrillic_key_invoice,
        bi.amount as summa_invoice,
        case 
            when pk.summa_rur > bi.amount then
                bi.amount    
            else
                pk.summa_rur
        end as to_distrib
    from psb_raw_keys pk inner join
        bank_invoices bi on {{ convert_to_cyrillic('upper(pk.key_invoice)') }} = bi.cyrillic_invoice_number   
    where key_invoice is not null
),
check_double_invoices as (
    select distinct
        foo.cyrillic_key_invoice
    from (
        select
            payment_key,
            cyrillic_key_invoice,
            max(summa_rur) payment_sum,
            sum(to_distrib) distrib_sum,
            max(summa_rur) - sum(to_distrib) delta_sum 
        from temp_distrib
        group by
            payment_key,
            cyrillic_key_invoice
        having
            max(summa_rur) - sum(to_distrib) = 0) as foo       
),
temp_distrib_clear as (
    select
        pk.source_id,
        pk.supplier_id,
        pk.hotel_supplier_id, 
        pk.payment_key,
        pk.payment_id,
        pk.number_doc,
        pk.account,
        pk.summa_rur,
        pk.created_at,    
        pk.cyrillic_key_invoice,
        pk.summa_invoice,
        case
            when di.cyrillic_key_invoice is not null and (pk.summa_rur - pk.to_distrib) <> 0 then
                0
            else     
                pk.to_distrib
        end as to_distrib    
    from
        temp_distrib pk left join
            check_double_invoices di 
            on pk.cyrillic_key_invoice = di.cyrillic_key_invoice    
),
temp_delta as (
    select
        payment_key,
        max(summa_rur) payment_sum,
        sum(to_distrib) distrib_sum,
        max(summa_rur) - sum(to_distrib) delta_sum 
    from temp_distrib_clear
    group by
        payment_key
    having
        max(summa_rur) - sum(to_distrib) <> 0
),
temp_delta_with_key as (
    select
        d.payment_key,
        i.cyrillic_key_invoice,
        d.delta_sum
    from 
        temp_delta as d inner join (             
            select 
                payment_key,
                max(cyrillic_key_invoice) as cyrillic_key_invoice
            from 
                temp_distrib_clear
            group by
                payment_key) as i  
                on d.payment_key = i.payment_key  
)
select
    pk.source_id,
    pk.supplier_id,
    pk.hotel_supplier_id,
    pk.payment_key,
    pk.payment_id,
    pk.number_doc,
    pk.account,
    pk.summa_rur,
    pk.created_at,    
    pk.cyrillic_key_invoice,
    pk.summa_invoice,
    pk.to_distrib + coalesce(d.delta_sum, 0) as to_distrib
from
    temp_distrib_clear pk left join temp_delta_with_key d 
        on pk.payment_key = d.payment_key and pk.cyrillic_key_invoice = d.cyrillic_key_invoice            