INSERT INTO operate.hotels (hotel_name) VALUES('Общее');
INSERT INTO operate.hotels (hotel_name) VALUES('Академическая');
INSERT INTO operate.hotels (hotel_name) VALUES('Авиамоторная');
INSERT INTO operate.hotels (hotel_name) VALUES('Ботанический');
INSERT INTO operate.hotels (hotel_name) VALUES('Измайловский');
INSERT INTO operate.hotels (hotel_name) VALUES('Каширский');
INSERT INTO operate.hotels (hotel_name) VALUES('Нахимовский');
INSERT INTO operate.hotels (hotel_name) VALUES('Покровский');
INSERT INTO operate.hotels (hotel_name) VALUES('Семеновский');
INSERT INTO operate.hotels (hotel_name) VALUES('Соколиная Гора');
INSERT INTO operate.hotels (hotel_name) VALUES('Таганская');
INSERT INTO operate.hotels (hotel_name) VALUES('Хамовники');
INSERT INTO operate.hotels (hotel_name) VALUES('Чистопрудный');
INSERT INTO operate.hotels (hotel_name) VALUES('Склад');
INSERT INTO operate.hotels (hotel_name) VALUES('Токмаков');


INSERT INTO operate.report_items (item_name) VALUES('Зарплата');
INSERT INTO operate.report_items (item_name) VALUES('Хозрасходы');
INSERT INTO operate.report_items (item_name) VALUES('Бензин');
INSERT INTO operate.report_items (item_name) VALUES('Прочее');


INSERT INTO operate.report_items (item_name) VALUES('Альфа КНМ');
INSERT INTO operate.report_items (item_name) VALUES('Корп карта ИП БАВ');


INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Авдеева','Ольга','Авдеева');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Быкова','Ирина','Быкова');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Пульчев','Денис','Пульчев');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Салдаев','Алексей','Салдаев');

INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Неверова','Инна','Неверова');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Сазонов','Андрей','Сазонов');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Новоженина','Диана','Новоженина');

INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Бабаев','','Бабаев');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Буланец','','Буланец');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Клубиков','','Клубиков');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Поляков','','Поляков');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Парамонова','','Парамонова');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Викулин','','Викулин');



INSERT INTO operate.sources (source_name, source_external_key, source_type) 
VALUES('Отчет Викулин Тест 1','1VSOfTBULFm2L2AgZ9-HLRO5QPivhpSAqpyd9jAz2KG8',1);

INSERT INTO operate.sources (source_name, source_external_key, source_type) 
VALUES('Отчет Тест 2','1NgQ1grPIRnayr5gyu9wB1kgN5hNzFN40od33nfEJjNQ',1);

INSERT INTO operate.sources (source_name, source_external_key, source_type) 
VALUES('Бабаев (отчет)','1AwOpsB7DHaRcNXS7fFp5x-NN69IhdS1y4jrDCWAaYIc',1);

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('BNOVO Учебный','BNOVO',2, '6390974362099+2177@customapp.bnovo.ru', '80bfbddc852cda96');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Bulanec 40802810900000081132','40802810900000081132',3, 'certificateBav.pfx', 'jhv098utDgTYT654IbW');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('Tinkoff Bulanec 40802810200000734551','40802810200000734551',4, Null, 't.bdr9ZePnL4k3fbqwPW-q6jPqdRO4kWsUruFzcLiVqVBWioppSjJSTp-c-APNew6Y8Lx6TK4CCV2XCHbL_4waTg');


INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Bulanec 40802810400003082832','40802810400003082832',3, 'certificateBav.pfx', 'jhv098utDgTYT654IbW');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Bulanec 40802810200003159952','40802810200003159952',3, 'certificateBav.pfx', 'jhv098utDgTYT654IbW');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Bulanec 40802810300003159218','40802810300003159218',3, 'certificateBav.pfx', 'jhv098utDgTYT654IbW');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Polyakov 40802810300003007030','40802810300003007030',3, 'certificatePol.pfx', 'SDGvg634!!fg');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Polyakov 40802810100000007000','40802810100000007000',3, 'certificatePol.pfx', 'SDGvg634!!fg');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Polyakov 45408810100000000066','45408810100000000066',3, 'certificatePol.pfx', 'SDGvg634!!fg');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Polyakov 45408810400000000067','45408810400000000067',3, 'certificatePol.pfx', 'SDGvg634!!fg');

INSERT INTO operate.sources (source_name, source_external_key, source_type, source_username, source_password) 
VALUES('PSB Polyakov 40802810000003182064','40802810000003182064',3, 'certificatePol.pfx', 'SDGvg634!!fg');



INSERT INTO operate.report_items (item_name) VALUES('TEST4');


with approve_items as (
	select
		ris.report_item_id as id 
	from 
		operate.report_items_setings ris
	where 
		ris.source_id in 
			(select id from operate.sources so where so.source_external_key = '1VSOfTBULFm2L2AgZ9-HLRO5QPivhpSAqpyd9jAz2KG8')
		and ris.view_permission = TRUE
)
select 
	ri.id,
	ri.item_name 
from 
	operate.report_items ri inner join
		approve_items ap on (ri.id = ap.id)
order by
    ri.order_count;
	

	
with find_source as (
	select 
		so.id 
	from operate.sources so 
	where so.source_external_key = '1VSOfTBULFm2L2AgZ9-HLRO5QPivhpSAqpyd9jAz2KG8'
	limit 1
)
select 
     ho.id, 
     ho.hotel_name 
from 
     operate.hotels ho inner join find_source so on (true); 
	
with income_debt as (
select 
	coalesce(sum(hist_str.sum_income) - sum(hist_str.sum_spend),0) as value
from
	operate.report_strings hist_str
where 
	hist_str.source_id = 4 and false
	--hist_str.applyed < TO_DATE('2023-04-01','YYYY-mm-DD')
)
SELECT 
	st.id,  
	--st.report_item_id, 
	st.report_date,
	nullif(st.sum_income, 0),
	st.sum_income,
	nullif(st.sum_spend, 0),
	st.sum_spend,
	coalesce(s.source_income_debt, 0) + coalesce((inc_dedt.value + sum(st.sum_income) over grow_total - sum(st.sum_spend) over grow_total)::FLOAT, 0) as debt,
	ri.item_name,
	h.hotel_name,
	st.string_comment,
	st.report_item_id,
	st.hotel_id,
	st.created, 
	st.applyed,
	st.parent_row_id 
FROM operate.report_strings st
	left join operate.report_items ri on st.report_item_id = ri.id
	left join operate.hotels h on st.hotel_id = h.id
	left join operate.sources s on st.source_id = s.id, 
	income_debt inc_dedt
where 
	st.source_id = 8 and 
	((applyed is null and 0=2) or 
		(applyed is not null and 0=1) or (2=2))
window grow_total as (order by 
	(case 
		when st.parent_row_id is not null and st.applyed is null then 2
		when st.applyed is null then 3
		else 1
	end), st.id)		
order by 
	(case 
		when st.parent_row_id is not null and st.applyed is null then 2
		when st.applyed is null then 3
		else 1
	end),
	st.id 
	;

    
delete from operate.report_strings 
where source_id = 8;

delete from operate.report_strings 
where report_item_id <= 15;

delete from operate.report_items  
where id <=15;

delete from operate.report_items_setings 
where 
source_id = 7;

delete from operate.report_items_setings 
where 
report_item_id  <= 15;

delete from operate.sources
where 
	id = 7;

select *
from operate.hotels h;

select *,
	'"' || ri.item_name || '"'
from operate.report_items ri
order by
	order_count;

select *
from operate.employees ri;

select *
from operate.report_items_setings ris; 

select *,
	extract(MONTH from s.source_data_begin) 
from operate.sources s;

update operate.report_items  
set 
	item_name = 'Викулин (отчет)'
where 
	id = 34;

select *
from operate.report_strings rs; 

select *
from operate.sources s;

delete 
	from operate.report_strings 
where
	applyed is not null and report_date is null and parent_row_id is null;

update operate.hotels 
set hotel_name = 'PUTIN KHUILO'
where id = 1;

update operate.report_strings
set
	applyed = null
where 	
	applyed is not null;

update operate.report_strings
set applyed = CURRENT_TIMESTAMP
where 
	applyed is null 
	and report_item_id is not null
	and ((sum_income = 0 and sum_spend <> 0) 
		or (sum_income <> 0 and sum_spend = 0));


	
update operate.report_items set order_count = 10 where item_name = 'Хозрасходы';
update operate.report_items set order_count = 20 where item_name = 'Зарплата';
update operate.report_items set order_count = 30 where item_name = 'Бензин';
update operate.report_items set order_count = 40 where item_name = 'Прочее';

update operate.report_items set order_count = 50 where item_name = 'Викулин (отчет)';
update operate.report_items set order_count = 60 where item_name = 'Бабаев (отчет)';
update operate.report_items set order_count = 70 where item_name = 'Буланец';
update operate.report_items set order_count = 80 where item_name = 'Клубиков';
update operate.report_items set order_count = 90 where item_name = 'Поляков';

update operate.report_items set order_count = 95 where item_name = 'Альфа КНМ';
update operate.report_items set order_count = 97 where item_name = 'Корп карта ИП БАВ';

update operate.report_items set order_count = 100 where item_name = 'Академическая';
update operate.report_items set order_count = 110 where item_name = 'Авиамоторная';
update operate.report_items set order_count = 120 where item_name = 'Ботанический';
update operate.report_items set order_count = 130 where item_name = 'Измайловский';
update operate.report_items set order_count = 140 where item_name = 'Каширский';
update operate.report_items set order_count = 150 where item_name = 'Нахимовский';
update operate.report_items set order_count = 160 where item_name = 'Покровский';
update operate.report_items set order_count = 170 where item_name = 'Семеновский';
update operate.report_items set order_count = 180 where item_name = 'Соколиная Гора';
update operate.report_items set order_count = 190 where item_name = 'Таганская';
update operate.report_items set order_count = 200 where item_name = 'Хамовники';
update operate.report_items set order_count = 210 where item_name = 'Чистопрудный';

update operate.report_items set order_count = 250 where item_name = 'Авдеева';
update operate.report_items set order_count = 260 where item_name = 'Быкова';
update operate.report_items set order_count = 270 where item_name = 'Пульчев';
update operate.report_items set order_count = 280 where item_name = 'Салдаев';
update operate.report_items set order_count = 290 where item_name = 'Бабаев';
update operate.report_items set order_count = 300 where item_name = 'Парамонова';
update operate.report_items set order_count = 310 where item_name = 'Неверова';
update operate.report_items set order_count = 320 where item_name = 'Сазонов';
update operate.report_items set order_count = 330 where item_name = 'Новоженина';
--update operate.report_items set order_count = 10 where item_name = 'Бабаев';
--update operate.report_items set order_count = 10 where item_name = 'Бабаев';





update operate.employees 
set first_name = 'Инна'
where id = 10;

update operate.sources
set source_income_debt = 0
where id = 4;


ALTER TABLE operate.report_items 
ADD source_id int,
ADD CONSTRAINT fk_source_items FOREIGN KEY ( source_id ) REFERENCES operate.sources  ( id );

 

alter table operate.report_items
drop column hotel_id; 

ALTER TABLE operate.report_strings  
ADD parent_row_id int;

ALTER TABLE operate.report_strings
add CONSTRAINT fk_parent_rows_reports FOREIGN KEY ( parent_row_id ) REFERENCES operate.report_strings ( id );

alter table operate.report_items 
add order_count int; 

alter table operate.sources 
add source_username varchar,
add	source_password varchar;

alter table operate.sources 
add source_data_begin date;



select 
	ri.id,
	ri.item_name,
	ri.order_count, 
	ri.empl_id,
	em.name_in_db,
	ri.source_id,
	so.source_name 
from 
	operate.report_items ri
	left join operate.employees em on ri.empl_id = em.id
	left join operate.sources so on ri.source_id = so.id 
	

with find_source as (
	select 
		so.id,
		so.source_name 
	from operate.sources so 
	where so.source_external_key = '1VSOfTBULFm2L2AgZ9-HLRO5QPivhpSAqpyd9jAz2KG8'
	limit 1
)
select
	so.id,
    so.source_name,  
	rs.report_item_id,
	ri.item_name,
    rs.view_permission  
from 
    operate.report_items_setings rs 
    inner join find_source so on (rs.source_id = so.id)
    left join operate.report_items ri on (rs.report_item_id = ri.id); 
   
   
select
	*
from 
	bnovo_raw.items;	

select
	*
from 
	bnovo_raw.hotels;

select
	*
from 
	bnovo_raw.suppliers;

select
	*
from 
	bnovo_raw.total_balance;

select
	*
from 
	bnovo_raw.balance_by_period;

select
	*
from 
	bnovo_raw.payments;

select
	*
from 
	bnovo_raw.payment_records;



select
	source_id,
	period_month,
	hotel_supplier_id,
	sum(case
		when amount > 0 then
			amount
		else
			0
	end) as debet,
	sum(case
		when amount < 0 then
			amount
		else
			0
	end) as credit
from 
	bnovo_raw.payment_records
group by
	source_id,
	period_month,
	hotel_supplier_id;


select
	source_id,
	extract(month from row_date)::varchar || extract(year from row_date)::varchar period_month,
	
	sum(case
		when not debit then
			summa_rur
		else
			0
	end) as income,
	sum(case
		when debit then
			summa_rur
		else
			0
	end) as outcome
from 
	banks_raw.psb_docs_rows
group by
	source_id,
	extract(month from row_date)::varchar || extract(year from row_date)::varchar;


select
	coalesce(sum(case
		when pr.amount > 0 then
			pr.amount
		else
			0
	end),0) as debet,
	coalesce(sum(case
		when pr.amount < 0 then
			pr.amount
		else
			0
	end),0) as credit
from 
	bnovo_raw.payment_records pr
	inner join bnovo_raw.suppliers s on pr.hotel_supplier_id = s.id and s.finance_supplier_id = '2084' 
where 
	pr.type_id = '2';

select *
from banks_raw.psb_docs dr;

select sum(dr.summa_rur)
from psb_bank_raw.docs_rows dr
group by
	dr.debit;

3966000.38	4898184.61
2023-03-01	2023-04-29


select * from banks_raw.loaded_data_by_period; 

select * from banks_raw.tinkoff_payments;

select * from banks_raw.ucb_payments;

select * from banks_raw.psb_acquiring_term;

select * from banks_raw.psb_docs_rows pd;

select * 
	
from banks_raw.psb_acquiring_qr paq;

select * from operate.report_items ri;

select * from bnovo_raw.bookings b 
where b.group_id is not null;



with plan as( 
            select 
                s.id source_id,
                period_plan.period_month,
                s.source_type,
                operate.end_of_month(period_plan.period_month) end_period
            from operate.sources s,
                operate.get_date_period_table_fnc(s.source_data_begin, (current_date - interval '1 day')::Date) period_plan
            where 
                s.source_data_begin is not null and s.source_type = 3)

        select
            p.source_id,
            to_char(coalesce(f.loaded_date, p.period_month),'dd.MM.yyyy') as datefrom,
            to_char(case 
                when p.period_month = date_trunc('month', (current_date - interval '1 day'))::Date then
                    (current_date - interval '1 day')::Date 
                else
                    p.end_period
            end,'dd.MM.yyyy') as dateto
        from 
            plan p left join banks_raw.loaded_data_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.loaded_date < p.end_period;

