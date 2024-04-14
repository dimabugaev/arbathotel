with psb_strings as (
    select * from {{ source('banks', 'psb_docs_rows') }}
)
select
	pdr.doc_id id,
	pdr.source_id,
	s.source_external_key as account_number,
	s.source_type, -- bank internal code
	pdr.row_date date_doc,
	pdr.row_date date_transaction,
	not pdr.debit as income,
	pdr.outer_account as contragent_account,
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
	end) OVER (partition by pdr.source_id ORDER BY pdr.row_date, pdr.doc_id) + COALESCE(s.source_income_debt,0) AS total_debt
from 
	psb_strings pdr join
	{{ ref('src_sources') }} s on pdr.source_id = s.id