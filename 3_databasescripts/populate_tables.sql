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
INSERT INTO operate.report_items (item_name) VALUES('Прочее');



select *
from operate.hotels h;

select *
from operate.report_items ri;

update operate.hotels 
set hotel_name = 'PUTIN KHUILO'
where id = 1;