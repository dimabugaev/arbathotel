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
	 source_type int NOT null,  -- 1 AO, 2 BINOVO, 3 PSB
	 source_external_key varchar NOT null,
	 source_income_debt decimal(18,2),
	 source_username varchar,
	 source_password varchar,
	 source_data_begin date
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

drop table if exists bnovo_raw.items;
drop table if exists bnovo_raw.hotels;
drop table if exists bnovo_raw.suppliers;
drop table if exists bnovo_raw.total_balance;
drop table if exists bnovo_raw.balance_by_period;
drop table if exists bnovo_raw.payments;
drop table if exists bnovo_raw.payment_records;
drop table if exists bnovo_raw.bookings;
drop table if exists bnovo_raw.guests;
drop table if exists bnovo_raw.booking_guests_link;
drop table if exists bnovo_raw.bookings_for_guests_request;
drop table if exists bnovo_raw.invoices;
drop table if exists bnovo_raw.temp_no_applyed_guests;
drop table if exists bnovo_raw.ufms_data;
drop table if exists bnovo_raw.load_bookings_by_period;


CREATE TABLE bnovo_raw.items
(
	source_id int, 
	id varchar,
	type_id varchar,
	name varchar,
	read_only varchar,
	create_date varchar,
	date_update timestamp not null default current_timestamp,

	 
	CONSTRAINT fk_sources_items FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.hotels
(
	source_id int, 
	id varchar,
	name varchar,
	country varchar,
	city varchar,
	address varchar,
	postcode varchar,
	phone varchar,
	email varchar,
	create_date varchar,
	date_update timestamp not null default current_timestamp,

	 
	CONSTRAINT fk_sources_hotels FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.suppliers
(
	source_id int, 
	id varchar,
	hotel_id varchar,
	name varchar,
	law_name varchar,
	email varchar,
	phone varchar,
	site varchar,
	city varchar,
	address varchar,
	law_address varchar,
	inn varchar,
	kpp varchar,
	account varchar,
	correspondent_account varchar,
	bik varchar,
	bank varchar,
	ogrn varchar,
	ceo varchar,
	finance_supplier_id varchar,
	date_update timestamp not null default current_timestamp,

	 
	CONSTRAINT fk_sources_suppliers FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.total_balance
(
	source_id int,
	finance_supplier_id varchar not null,
	last_payment_balance decimal(18,2) not null default 0,
	last_payment_cash_balance decimal(18,2) not null default 0,
	date_update timestamp not null default current_timestamp,
	
	CONSTRAINT fk_sources_total_balance FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.balance_by_period
(
	source_id int,
	period_month date not null,
	finance_supplier_id varchar not null,
	debet decimal(18,2) not null default 0,
	credit decimal(18,2) not null default 0,
	debet_cash decimal(18,2) not null default 0,
	credit_cash decimal(18,2) not null default 0,
	date_update timestamp not null default current_timestamp,
	
	CONSTRAINT fk_sources_total_balance_by_period FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.load_bookings_by_period
(
	source_id int,
	period_month date not null,
	date_update timestamp not null default current_timestamp,
	
	CONSTRAINT fk_sources_total_booking_by_period FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.payments
(
	source_id int,
	period_month date not null,
	id varchar,
	supplier_id varchar,
	contractor_id varchar,
	external_hotel_id varchar,
	external_booking_id varchar,
	external_user_id varchar,
	external_user_name varchar,
	external_payment_id varchar,
	external_supplier_id varchar,
	passport varchar,
	name varchar,
	type_id varchar,
	item_id varchar,
	amount varchar,
	balance varchar,
	paid_date varchar,
	reason varchar,
	create_date varchar,
	fiscal_status varchar,
	sub_amount varchar,
	id_command varchar,
	date_update timestamp not null default current_timestamp,
 
	CONSTRAINT fk_sources_payments FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.payment_records
(
	source_id int,
	period_month date not null,
	id varchar,
	payment_id varchar,
	booking_id varchar,
	booking_number varchar,
	item_id varchar,
	method_id varchar,
	subject_id varchar,
	service_id varchar,
	service_name varchar,
	origin_country varchar,
	customs_doc_number varchar,
	excise_sum varchar,
	amount decimal(18,2),
	sub_amount varchar,
	nds_value varchar,
	tax_system varchar,
	is_for_booking varchar,
	hotel_supplier_id varchar,
	supplier_id varchar,
	type_id varchar,
	name varchar,
	reason varchar,
	paid_date varchar,
	transferred_refund_id varchar,
	transferred_to_booking_number varchar,
	passport varchar,
	finance_goal varchar,
	date_update timestamp not null default current_timestamp,
 
	CONSTRAINT fk_sources_payment_records FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);


CREATE TABLE bnovo_raw.bookings
(
	source_id int,
	period_month date not null,
	id varchar,
    hotel_id varchar,
    origin_source_id varchar,
    provider_id varchar,
    source_name varchar,
    source_icon varchar,
    status_id varchar,
    status_name varchar,
    status_color varchar,
    customer_id varchar,
    agency_id varchar,
    supplier_id varchar,
    supplier_name varchar,
    agency_name varchar,
    agency_commission decimal(18,2),
    agency_not_pay_services_commission varchar,
    source_commission varchar,
    ancillary_commission varchar,
    number varchar,
    create_date varchar,
    arrival varchar,
    departure varchar,
    real_arrival varchar,
    real_departure varchar,
    original_arrival varchar,
    original_departure varchar,
    amount varchar,
    amount_provider varchar,
    is_blocked varchar,
    name varchar,
    surname varchar,
    phone varchar,
    notes varchar,
    link_id varchar,
    external_res_id varchar,
    provider_booking_id varchar,
    extra_provider varchar,
    cancel_date varchar,
    discount_type varchar,
    discount_amount varchar,
    discount_reason_id varchar,
    discount_reason varchar,
    guarantee varchar,
    is_guarantee_encrypted varchar,
    prices_services_total varchar,
    prices_rooms_total varchar,
    payments_total varchar,
    provided_total varchar,
    customers_total varchar,
    plan_name varchar,
    initial_room_type_name varchar,
    current_room varchar,
    current_room_clean_status varchar,
    room_name varchar,
    has_linked_bookings varchar,
    has_linked_cancelled_bookings varchar,
    early_check_in varchar,
    late_check_out varchar,
    unread varchar,
    uu varchar,
    created_user varchar,
    created_user_id varchar,
    created_user_name varchar,
    created_user_surname varchar,
    group_id varchar,
    group_code varchar,
    group_name varchar,
    group_create_date varchar,
    actual_price varchar,
    email varchar,
    customer_notes varchar,
    ota_info varchar,
    cancel_reason varchar,
    discount_reason_relation varchar,
    board_nutritia varchar,
    online_warranty_deadline_date varchar,
    auto_booking_cancel varchar,
    adults decimal(10,0),
    children decimal(10,0),
    date_update timestamp not null default current_timestamp,
 
	CONSTRAINT fk_sources_bookings FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.guests
(
	source_id int,
	id varchar,
    hotel_id varchar,
    country_id varchar,
    country_name varchar,
    citizenship_id varchar,
    citizenship_name varchar,
    name varchar,
    surname varchar,
    email varchar,
    phone varchar,
    birthdate varchar,
    postcode varchar,
    city varchar,
    address varchar,
    passport_num varchar,
    passport_date_start varchar,
    passport_date_end varchar,
    notes varchar,
    tags varchar,
    guest_type varchar,
    gender varchar,
    middlename varchar,
    birth_country_name varchar,
    birth_country_id varchar,
    birth_region_name varchar,
    birth_area_name varchar,
    birth_city_name varchar,
    birth_locality_name varchar,
    document_type varchar,
    document_series varchar,
    document_number varchar,
    document_unit_code varchar,
    document_organization_issued varchar,
    document_date_issued varchar,
    document_date_end varchar,
    address_free varchar,
    address_fias varchar,
    address_region varchar,
    address_region_only varchar,
    address_area_only varchar,
    address_street_name varchar,
    address_house varchar,
    address_housing varchar,
    address_flat varchar,
    address_date varchar,
    migcard_series varchar,
    migcard_number varchar,
    migcard_date_arrival varchar,
    migcard_kpp varchar,
    migcard_kpp_code varchar,
    migcard_date_start varchar,
    migcard_date_end varchar,
    representative_customer_id varchar,
    relationtype_id varchar,
    representative_customer_full_name varchar,
    date_update timestamp not null default current_timestamp,
    
	CONSTRAINT fk_sources_guests FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE bnovo_raw.booking_guests_link
(
	source_id int,
	booking_id varchar,
	guest_id varchar,
	date_update timestamp not null default current_timestamp,
	
	CONSTRAINT fk_sources_booking_guests_link FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id ),
	CONSTRAINT unique_source_booking_guest UNIQUE (source_id, booking_id, guest_id)
);

CREATE TABLE bnovo_raw.temp_no_applyed_guests
(
	source_id int,
	guest_id varchar,
	
	CONSTRAINT fk_sources_no_applyed_guests FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id ),
	CONSTRAINT unique_source_no_applyed_guest UNIQUE (source_id, guest_id)
);

CREATE TABLE bnovo_raw.ufms_data
(
	source_id int,
	id varchar,
    hotel_id varchar,
    booking_id varchar,
    customer_id varchar,
    status varchar,
    scala_id varchar,
    scala_number varchar,
    last_error varchar,
    last_attempt_date varchar,
    create_date varchar,
    update_date varchar,
    scala_status varchar,
    citizenship_id varchar,
    arrival varchar,
    departure varchar,
    customer_name varchar,
    customer_surname varchar,
	date_update timestamp not null default current_timestamp,
    
	CONSTRAINT fk_sources_ufms FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);
                    
CREATE TABLE bnovo_raw.invoices
(
	source_id int,
	--period_month date not null,
    id varchar,
    number varchar,
    hotel_id varchar,
    booking_id varchar,
    booking_number varchar,
    supplier_id varchar,
    supplier varchar,
    customer_id varchar,
    customer varchar,
    hotel_supplier_id varchar,
    hotel_supplier varchar,
    type_id varchar,
    supplier_type_id varchar,
    amount varchar,
    deadline_date varchar,
    message varchar,
    vat varchar,
    create_date varchar,
    payer_name varchar,
    amount_nds varchar,
    online_number varchar,
    online_hash varchar,
    online_link varchar,
    payed_amount varchar,
    unread varchar,
    paid_from_system varchar,
    message_for_invoices varchar,
    payment_system_name varchar,
    group_id varchar,
    tax_system_id varchar,
    denied_from_system varchar,
    denied_payment_system_name varchar,
    deactivated varchar,
    refunded varchar,
    delivery_acts varchar,
    date_update timestamp not null default current_timestamp,
 
	CONSTRAINT fk_sources_invoices FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

create schema if not exists banks_raw;

drop table if exists banks_raw.psb_docs_rows;
drop table if exists banks_raw.psb_docs;
drop table if exists banks_raw.loaded_data_by_period;

drop table if exists banks_raw.tinkoff_payments;
drop table if exists banks_raw.ucb_payments;

drop table if exists banks_raw.psb_acquiring_term;
drop table if exists banks_raw.psb_acquiring_qr;
drop table if exists banks_raw.psb_acquiring_qr_refund;



CREATE TABLE banks_raw.psb_docs
(
	id bigint,
    source_id int,
    bank_work_id bigint,
    row_date date,
    first_signed boolean,
    number_doc varchar,
    reciever varchar,
    second_signed boolean,
    summa decimal(18,2),
    third_signed boolean,
    date_update timestamp not null default current_timestamp,
    
    CONSTRAINT fk_sources_psb_docs FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE banks_raw.psb_docs_rows
(
    source_id int,
    doc_id bigint,
    row_date date,
    kb varchar,
    po varchar,
    account varchar,
    contragent varchar,
    contragent_inn varchar,
    conversion decimal(18,2),
    debit boolean,
    description varchar,
    outer_account varchar,
    summa_rur decimal(18,2),
    date_update timestamp not null default current_timestamp,
    
    CONSTRAINT fk_sources_psb_docs_rows FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE banks_raw.loaded_data_by_period
(
    source_id int,
    period_month date,
    loaded_date date,
    debet decimal(18,2),
    credit decimal(18,2),
    date_update timestamp not null default current_timestamp,
    
    CONSTRAINT fk_sources_loaded_data FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id ),
    CONSTRAINT loaded_data_by_period_uniq UNIQUE (source_id, period_month)
);


CREATE TABLE banks_raw.tinkoff_payments
(
    source_id int,
    period_month date,
    id varchar,
    date varchar,
    amount varchar,
    draw_date varchar,
    payer_name varchar,
    payer_inn varchar,
    payer_account varchar,
    payer_corr_account varchar,
    payer_bic varchar,
    payer_bank varchar,
    charge_date varchar,
    recipient varchar,
    recipient_inn varchar,
    recipient_account varchar,
    recipient_corr_account varchar,
    recipient_bic varchar,
    recipient_bank varchar,
    operation_type varchar,
    payment_purpose varchar,
    creator_status varchar,
    recipient_kpp varchar,
    execution_order varchar,
    date_update timestamp not null default current_timestamp,
    
    CONSTRAINT fk_sources_tinkoff_payments FOREIGN KEY ( source_id ) REFERENCES operate.sources ( id )
);

CREATE TABLE banks_raw.ucb_payments
(
    account varchar,
    draw_date varchar,
    operation_date varchar,
    operation_code varchar,
    bank_corr_bic varchar,
    bank_corr_account varchar,
    bank_corr_name varchar,
    corr_account varchar,
    correspondent varchar,
    doc_number varchar,
    doc_data varchar,
    debet varchar,
    credit varchar,
    rub_cover varchar,
    code varchar,
    description varchar,
    corr_inn varchar,
    paiment_order varchar,
    date_update timestamp not null default current_timestamp
    
);

CREATE TABLE banks_raw.psb_acquiring_term
(
    contract_name varchar,
    device_name varchar,
    device_number varchar,
    device_addr varchar,
    currency varchar,
    payment_system varchar,
    card_number varchar,
    operation_data varchar,
    processing_data varchar,
    operation_sum varchar,
    commission varchar,
    to_transaction varchar,
    rpn varchar UNIQUE,
    operation_type varchar,
    original_sum varchar,
    original_currency varchar,
    order_number varchar,
    description varchar,
    date_update timestamp not null default current_timestamp
    
);

CREATE TABLE banks_raw.psb_acquiring_qr
(
    date_time varchar,
    id_payment varchar UNIQUE,
    id_qr varchar,
    payer_bank varchar,
    payer_name varchar,
    payer_account varchar,
    recipient_inn varchar,
    recipient_name varchar,
    terminal_number varchar,
    tsp_name varchar,
    tsp_addr varchar,
    recipient_account varchar,
    mss varchar,
    operation_sum varchar,
    operation_com varchar,
    to_tramsaction varchar,
    currency varchar,
    about_payment varchar,
    description varchar,
    date_update timestamp not null default current_timestamp
    
);

CREATE TABLE banks_raw.psb_acquiring_qr_refund
(
    date_time_original varchar,
	date_time_refund varchar,
    id_payment_refund varchar UNIQUE,
    id_payment_original varchar,
    terminal_number varchar,
    tsp_addr varchar,
    recipient_name varchar,
    recipient_refund_account varchar,
    payer_account varchar,
    payer_tsp_name varchar,
    tsp_id varchar,
    refund_sum varchar,
    original_sum varchar,
    about_refund_payment varchar,
    about_original_payment varchar,
    payer_bank varchar,
    date_update timestamp not null default current_timestamp
    
);

CREATE OR REPLACE FUNCTION operate.get_date_period_table_fnc(start_date DATE, end_date DATE)
  RETURNS table (period_month DATE) AS
$$
BEGIN
  return query
  with recursive dates as (
	
	select 
		start_date date_val
		
	union all
	
	select
		(date_val + interval '1 month')::Date date_val
	from
		dates
	where 
		date_val < date_trunc('month', end_date)::Date
	
	)
	select 
		date_val
	from 
		dates;	
END;
$$
LANGUAGE 'plpgsql';

create function operate.end_of_month(date)
returns date as
$$
select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date;
$$ language 'sql'
immutable strict;
