create schema if not exists operate;

--drop trigger if exists hotels_insert_trigger ON operate.hotels;
--drop procedure if exists operate.hotel_insert_trigger_fnc;

--drop trigger if exists hotels_update_trigger ON operate.hotels;
--drop procedure if exists operate.hotel_update_trigger_fnc;


drop table if exists operate.report_strings;
drop table if exists operate.report_items_setings;
drop table if exists operate.report_items;
drop table if exists operate.employees;
drop table if exists operate.sources;
drop table if exists operate.hotels;


CREATE TABLE operate.hotels
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 hotel_name varchar NOT NULL
);


CREATE TABLE operate.sources
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 source_name varchar NOT null,
	 source_type int NOT null,
	 source_external_key varchar NOT null,
	 source_income_debt decimal(18,2),
	 source_username varchar,
	 source_password varchar
);
 
 
CREATE OR REPLACE FUNCTION operate.source_update_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
 UPDATE operate.report_items 
 SET item_name = NEW.source_name, source_id = NEW.id
 WHERE source_id = OLD.id;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER sources_update_trigger
  AFTER UPDATE
  ON operate.sources
  FOR EACH row
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE operate.source_update_trigger_fnc();


CREATE TABLE operate.employees
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 last_name varchar NOT null,
	 first_name varchar NOT null,
	 name_in_db varchar NOT null
);

CREATE TABLE operate.report_items
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 item_name varchar NOT null,
--	 hotel_id int,
	 empl_id int,
	 source_id int,
	 order_count int,
	 
--	 CONSTRAINT fk_hotels_items FOREIGN KEY ( hotel_id ) REFERENCES operate.hotels ( id ),
	 CONSTRAINT fk_empl_items FOREIGN KEY ( empl_id ) REFERENCES operate.employees ( id ),
	 CONSTRAINT fk_source_items FOREIGN KEY ( source_id ) REFERENCES operate.sources  ( id )
);



CREATE TABLE operate.report_items_setings
(
	 source_id int NOT null,
	 report_item_id int NOT null,
	 view_permission boolean,
	 
	 

	 CONSTRAINT report_items_setings_pk PRIMARY KEY (source_id, report_item_id),
	 CONSTRAINT fk_sources_setings FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id ),
	 CONSTRAINT fk_items_setings FOREIGN KEY ( report_item_id ) REFERENCES operate.report_items ( id )
);

-- triggers add SOURCES

CREATE OR REPLACE FUNCTION operate.source_insert_trigger_fnc()
  RETURNS trigger AS
$$
begin
	
	INSERT INTO operate.report_items ( item_name, source_id )
	VALUES(NEW.source_name, NEW.id);

 	INSERT INTO operate.report_items_setings ( source_id, report_item_id, view_permission)
	select 
		NEW.id as source_id,
		ri.id as report_item_id,
		true as view_permission
	from 
		operate.report_items ri
		left join operate.report_items_setings its 
			on NEW.id = its.source_id and ri.id = its.report_item_id 
	where 
		its.source_id is null;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER sources_insert_trigger
  AFTER INSERT
  ON operate.sources
  FOR EACH ROW
  EXECUTE PROCEDURE operate.source_insert_trigger_fnc();

-- triggers ITEMS
 
CREATE OR REPLACE FUNCTION operate.report_item_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
	INSERT INTO operate.report_items_setings ( source_id, report_item_id, view_permission)
	select 
		so.id as source_id,
		NEW.id as report_item_id,
		true as view_permission
	from 
		operate.sources so;
	
	update operate.report_items 
	set 
		order_count = (select coalesce(MAX(order_count),0) + 10 from operate.report_items)
	where 
		id = new.id;
	
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER report_items_trigger
  AFTER INSERT
  ON operate.report_items
  FOR EACH ROW
  EXECUTE PROCEDURE operate.report_item_insert_trigger_fnc();
 
----------------------


CREATE TABLE operate.report_strings
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 source_id int NOT null,
	 report_item_id int,
	 created timestamp not null default current_timestamp,
	 applyed timestamp,
	 report_date date,
	 hotel_id int,
	 sum_income decimal(18,2),
	 sum_spend decimal(18,2),
	 string_comment varchar,
	 parent_row_id int,
	 
	 CONSTRAINT fk_sources_reports FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id ),
	 CONSTRAINT fk_items_reports FOREIGN KEY ( report_item_id ) REFERENCES operate.report_items ( id ),
	 CONSTRAINT fk_hotels_reports FOREIGN KEY ( hotel_id ) REFERENCES operate.hotels ( id ),
	 CONSTRAINT fk_parent_rows_reports FOREIGN KEY ( parent_row_id ) REFERENCES operate.report_strings ( id )
);

-- triggers for clone strings
CREATE OR REPLACE FUNCTION operate.report_string_insert_trigger_fnc()
  RETURNS trigger AS
$$
declare
	v_source_id INT;
	v_item_id INT;
begin
	select ri.source_id into v_source_id
	from 
		operate.report_items ri
		left join operate.sources so on ri.source_id = so.id 
	where
		ri.source_id is not null
		and so.source_type = 1
		and ri.id = new.report_item_id;
		
	-- exception when no_data_found then v_source_id := null;
		
	
	if found AND new.parent_row_id is null then
		select id into v_item_id
		from 
			operate.report_items
		where
			source_id = new.source_id;
	
		if not found then
			v_item_id := null;	
		end if;
		
		INSERT INTO operate.report_strings  
		 ( source_id, report_item_id, report_date, hotel_id, sum_income, sum_spend, string_comment, parent_row_id, applyed  )
		VALUES(v_source_id, v_item_id, new.report_date, new.hotel_id, new.sum_spend, new.sum_income, new.string_comment, new.id, new.applyed);
	
	end if;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER report_strings_insert_trigger
  AFTER INSERT
  ON operate.report_strings
  FOR EACH ROW
  EXECUTE PROCEDURE operate.report_string_insert_trigger_fnc();
 
 
CREATE OR REPLACE FUNCTION operate.report_string_update_trigger_fnc()
  RETURNS trigger AS
$$
declare
	v_source_id INT;
	v_item_id INT;
begin
	select ri.source_id into v_source_id
	from 
		operate.report_items ri
		left join operate.sources so on ri.source_id = so.id 
	where
		ri.source_id is not null
		and so.source_type = 1
		and ri.id = new.report_item_id;
		
	-- exception when no_data_found then v_source_id := null;
		
	
	if found AND new.parent_row_id is null then
		select id into v_item_id
		from 
			operate.report_items
		where
			source_id = new.source_id;
	
		if not found then
			v_item_id := null;	
		end if;
		
		UPDATE operate.report_strings
		SET
		 source_id = v_source_id, 
		 report_item_id = v_item_id, 
		 report_date = new.report_date, 
		 hotel_id = new.hotel_id, 
		 sum_income = new.sum_spend, 
		 sum_spend = new.sum_income, 
		 string_comment = new.string_comment, 
		 parent_row_id = new.id,
		 applyed = new.applyed
		where 
			parent_row_id = old.id;
	
	end if;

RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

CREATE TRIGGER report_strings_update_trigger
  AFTER UPDATE
  ON operate.report_strings
  FOR EACH row
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE operate.report_string_update_trigger_fnc();
 
 
 
CREATE OR REPLACE FUNCTION operate.report_string_before_delete_trigger_fnc() RETURNS trigger AS
$$BEGIN


   delete from operate.report_strings
   where
	parent_row_id = old.id;

   RETURN OLD;
END;$$ LANGUAGE 'plpgsql';

CREATE TRIGGER report_strings_before_delete_trigger
   BEFORE DELETE ON operate.report_strings FOR EACH ROW
   EXECUTE PROCEDURE operate.report_string_before_delete_trigger_fnc();

-- triggers add update HOTELS
/*
CREATE OR REPLACE FUNCTION operate.hotel_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
 INSERT INTO operate.report_items ( item_name, hotel_id )
VALUES(NEW.hotel_name,NEW.id);
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER hotels_insert_trigger
  AFTER INSERT
  ON operate.hotels
  FOR EACH ROW
  EXECUTE PROCEDURE operate.hotel_insert_trigger_fnc();
 
drop trigger hotels_insert_trigger on operate.hotels;
drop trigger hotels_update_trigger on operate.hotels;
drop function operate.hotel_update_trigger_fnc();
drop function operate.hotel_insert_trigger_fnc();
 
 
CREATE OR REPLACE FUNCTION operate.hotel_update_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
 UPDATE operate.report_items 
 SET item_name = NEW.hotel_name, hotel_id = NEW.id
 WHERE hotel_id = OLD.id;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER hotels_update_trigger
  AFTER UPDATE
  ON operate.hotels
  FOR EACH row
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE operate.hotel_update_trigger_fnc(); */
 
-- triggers add update EMPLOYEES 
 
CREATE OR REPLACE FUNCTION operate.employee_insert_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
 INSERT INTO operate.report_items ( item_name, empl_id )
VALUES(new.name_in_db, NEW.id);
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER employees_insert_trigger
  AFTER INSERT
  ON operate.employees
  FOR EACH ROW
  EXECUTE PROCEDURE operate.employee_insert_trigger_fnc();
 
 
CREATE OR REPLACE FUNCTION operate.employee_update_trigger_fnc()
  RETURNS trigger AS
$$
BEGIN
 UPDATE operate.report_items 
 SET item_name = NEW.name_in_db, empl_id = new.id
 WHERE empl_id = OLD.id;
RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';


CREATE TRIGGER hotels_update_trigger
  AFTER UPDATE
  ON operate.employees
  FOR EACH row
  WHEN (OLD.* IS DISTINCT FROM NEW.*)
  EXECUTE PROCEDURE operate.employee_update_trigger_fnc();
 
 
 
create schema if not exists bnovo_raw;

CREATE TABLE bnovo_raw.hotels
(
	 id	int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
	 hotel_name varchar NOT NULL
);
 

