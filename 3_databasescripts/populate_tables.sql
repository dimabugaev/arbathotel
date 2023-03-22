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

INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Неверова','Ирина','Неверова');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Сазонов','Андрей','Сазонов');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Новоженина','Диана','Новоженина');

INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Бабаев','','Бабаев');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Буланец','','Буланец');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Клубиков','','Клубиков');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Поляков','','Поляков');
INSERT INTO operate.employees (last_name, first_name, name_in_db) VALUES('Парамонова','','Парамонова');



INSERT INTO operate.sources (source_name, source_external_key, source_type) 
VALUES('Отчет Викулин Тест 1','1VSOfTBULFm2L2AgZ9-HLRO5QPivhpSAqpyd9jAz2KG8',1);

INSERT INTO operate.sources (source_name, source_external_key, source_type) 
VALUES('Отчет Тест 2','1NgQ1grPIRnayr5gyu9wB1kgN5hNzFN40od33nfEJjNQ',1);




with approve_items as (
	select
		ris.report_item_id as id 
	from 
		operate.report_items_setings ris
	where 
		ris.source_id in 
			(select id from operate.sources so where so.source_external_key = '12345')
		and ris.view_permission = TRUE
)
select 
	ri.id,
	ri.item_name 
from 
	operate.report_items ri inner join
		approve_items ap on (ri.id = ap.id);
	

	
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
	

SELECT 
	st.id,  
	--st.report_item_id, 
	st.report_date,
	st.sum_income,
	st.sum_spend,
	0 debt,
	ri.item_name,
	h.hotel_name,
	st.string_comment,
	st.report_item_id,
	st.hotel_id,
	st.created, 
	st.applyed
FROM operate.report_strings st
	left join operate.report_items ri on st.report_item_id = ri.id
	left join operate.hotels h on st.hotel_id = h.id 
where 
	source_id = 4 and 
	((applyed is null and 0=2) or 
		(applyed is not null and 0=1) or (2=2))
order by 
	st.applyed is null,
	st.id 
	;

    
select *
from operate.hotels h;

select *
from operate.report_items ri;

select *
from operate.employees ri;

select *
from operate.report_items_setings ris; 

select *
from operate.sources s;

select *
from operate.report_strings rs; 

delete 
	from operate.report_strings 
where
	applyed is null and source_id = 3;

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




                     