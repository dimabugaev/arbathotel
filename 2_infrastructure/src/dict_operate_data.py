import my_utility
import re
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver
from typing import Any
from datetime import datetime
import pytz

#from datetime import date, timedelta, datetime



connection = my_utility.get_db_connection()

app = APIGatewayHttpResolver()

def get_date_from_string_to_query(str_date: str) -> str:
    result = "NULL"

    #2023-01-03T08:00:00.000Z
    format = '%Y-%m-%dT%H:%M:%S.%f%z'
    tz = pytz.timezone("Europe/Moscow")
    if isinstance(str_date, str):
        try:
            moscow_date = tz.normalize(datetime.strptime(str_date, format).astimezone(tz))
            report_date = my_utility.get_begin_month_by_date(moscow_date.date())
            result = "TO_DATE('" + str(str(report_date)) + "','YYYY-mm-DD')"
        except:
            result = "NULL"

    return result

def get_booking_problems_state() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select
                        m.problem_id,
                        m.hotel_id,
                        m.hotel,
                        m.booking_id,
                        m.booking_number,
                        m.booking_link,
                        m.status_id,
                        m.status_name,
                        m.plan_arrival_date,
                        m.plan_departure_date,
                        m.adults,
                        m.children,
                        m.err_status_id,
                        m.err_status_name,
                        m.updated_at,
                        m.guest_id,
                        m.name,
                        m.surname,
                        m.citizenship_name,
                        m.birthdate,
                        m.address_free,
                        m.document_type,
                        m.document_series,
                        m.document_number,
                        m.guests_link,
                        coalesce(s.comment, '') comment,
                        coalesce(s.corrected, False) corrected,
                        coalesce(s.checked, false) checked
                    from 
                        public.mart_booking_problem m left join operate.booking_problems_state s
                        on m.problem_id = s.id
                    --where 
                    --    s.checked is null or not s.checked
                    order by
                        m.plan_arrival_date""")
    
    return cursor.fetchall()

def get_canceled_booking_state() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select
                        *
                    from 
                        public.mart_canceled_bookings""")
    
    return cursor.fetchall()


def get_company_acts_state(inn, date_month) -> list:
    global connection

    format = '%Y-%m-%d'

    cursor = connection.cursor()
    
    cursor.execute(""" select
                            a.*,
                            s.inn,
                            h."name" 
                        from 
                            bnovo_raw.acts a 
                            join bnovo_raw.suppliers s on a.hotel_supplier_id = s.id 
                            join bnovo_raw.hotels h on a.hotel_id = h.id
                        where 
                            supplier_id <> '0' and
                            date_trunc('month', a.create_date::date) = %(date_month)s
                            and s.inn = %(inn)s""", {'date_month': datetime.strptime(date_month, format), 'inn': inn})
    
    return cursor.fetchall()

def get_users_sales_state() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select
                        *
                    from 
                        public.mart_users_sales""")
    
    return cursor.fetchall()

def put_booking_problems_state(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
            list_of_args = []
            for newrow in datastrings:

                if (len(str(newrow[0])) == 0 
                    and len(str(newrow[1])) == 0 
                    and len(str(newrow[2])) == 0 
                    and len(str(newrow[3])) == 0):
                    continue
                
                list_of_args.append("('{}', {}, {}, '{}')"
                    .format(newrow[0], #id
                    "true" if newrow[1] == '1' else "false",         #checked
                    "true" if newrow[2] == '1' else "false",         #corrected
                    newrow[3]))        #comment                               

            if len(list_of_args) > 0:

                args_str = ','.join(list_of_args)
                cursor.execute("""INSERT INTO operate.booking_problems_state
                                    (id, checked, corrected, comment)
                                    VALUES """ + args_str  + """
                                    on conflict (id) do update
                                        set 
                                            checked = EXCLUDED.checked,
                                            corrected = EXCLUDED.corrected,
                                            comment = EXCLUDED.comment
                                    """)
                connection.commit()
        except Exception as ex:
            connection.rollback()
            raise ex

def get_sources() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select 
                        s.id,
                        s.source_name,
                        s.source_type, 
                        s.source_external_key,
                        s.source_income_debt::FLOAT,
                        s.source_username,
                        s.source_password,
                        s.source_data_begin 
                      from 
                        operate.sources s
                      order by
                        s.id""")
    
    return cursor.fetchall()
                            
def get_hotels() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select 
                        h.id,
                        h.hotel_name,
                        h.bnovo_id,
                        h.synonyms 
                      from 
                        operate.hotels h
                      order by
                        h.id""")
    
    return cursor.fetchall()

def get_devices() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select 
                        d.id,
                        d.hotel_id,
                        d.source_id
                      from 
                        operate.devices d
                      order by
                        d.id""")
    
    return cursor.fetchall()

def get_employees() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select 
                        e.id,
                        e.last_name,
                        e.first_name, 
                        e.name_in_db 
                      from 
                        operate.employees e
                      order by
                        e.id""")
    
    return cursor.fetchall()

def get_report_items() -> list:

    global connection

    cursor = connection.cursor()
    
    cursor.execute("""select 
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
                      order by
                        ri.order_count""")
    
    return cursor.fetchall()

def get_report_settings(source_id : str) -> list:

    global connection

    if re.match('\S+', source_id) is None: # bad string
        return my_utility.get_response({'FormatError': source_id})
    
    cursor = connection.cursor()
    
    cursor.execute("""with find_source as (
                            select 
                                so.id,
                                so.source_name 
                            from operate.sources so 
                            where so.source_external_key = %(source_key)s
                            limit 1
                        )
                        select
                            rs.source_id,
                            so.source_name,  
                            rs.report_item_id,
                            ri.item_name,
                            rs.view_permission  
                        from 
                            operate.report_items_setings rs 
                            inner join find_source so on (rs.source_id = so.id)
                            left join operate.report_items ri on (rs.report_item_id = ri.id)
                        order by
                            ri.order_count""", {'source_key': source_id})
    
    return cursor.fetchall()


def put_sources(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0 
                  and len(str(newrow[2])) == 0 
                  and len(str(newrow[3])) == 0 
                  and len(str(newrow[4])) == 0
                  and len(str(newrow[5])) == 0
                  and len(str(newrow[6])) == 0
                  and len(str(newrow[7])) == 0):
                  continue
              
              list_of_args.append("({}, '{}', {}, '{}', {}, '{}', '{}', {})"
                  .format(my_utility.num_to_query_substr(newrow[0]), #id
                  newrow[1],                                         #source_name
                  my_utility.num_to_query_substr(newrow[2]),         #source_type
                  newrow[3],                                         #source_external_key
                  my_utility.num_to_query_substr(newrow[4]),         #source_income_debt
                  newrow[5],                                         #source_username
                  newrow[6],                                         #source_password
                  get_date_from_string_to_query(newrow[7])))         #source_data_begin                               

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_source_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_source_table_update AS SELECT * FROM operate.sources WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_source_table_update
                                (id, source_name, source_type, source_external_key, source_income_debt, source_username, source_password, source_data_begin)
                              VALUES """ + args_str)
            

            cursor.execute("""
                    
                    UPDATE operate.sources t
                        SET source_name = u.source_name,
                            source_type = u.source_type,
                            source_external_key = u.source_external_key,
                            source_income_debt = u.source_income_debt,
                            source_username = u.source_username,
                            source_password = u.source_password,
                            source_data_begin = u.source_data_begin
                    FROM operate.sources s
                        INNER JOIN temp_source_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.source_name, s.source_type, s.source_external_key, s.source_income_debt, s.source_username, s.source_password, s.source_data_begin
                        EXCEPT
                        SELECT u.source_name, u.source_type, u.source_external_key, u.source_income_debt, u.source_username, u.source_password, u.source_data_begin
                        ) and t.id = s.id;

                    INSERT INTO operate.sources (source_name, source_type, source_external_key, source_income_debt, source_username, source_password, source_data_begin)
                    SELECT     
                        source_name, 
                        source_type, 
                        source_external_key, 
                        source_income_debt,
                        source_username,
                        source_password,
                        source_data_begin
                    FROM temp_source_table_update
                    WHERE
                        id is NULL;
                    """)


            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex


def put_hotels(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0
                  and len(str(newrow[2])) == 0
                  and len(str(newrow[3])) == 0):
                  continue
              

              list_of_args.append("({}, '{}', '{}', '{}')"
                  .format(my_utility.num_to_query_substr(newrow[0]), #id
                  newrow[1],                                         #hotel_name
                  newrow[2],                                         #bnovo_id
                  newrow[3]))                                        #synonyms
                  

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_hotels_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_hotels_table_update AS SELECT * FROM operate.hotels WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_hotels_table_update
                                (id, hotel_name, bnovo_id, synonyms)
                              VALUES """ + args_str)
            

            cursor.execute("""                    
                    UPDATE operate.hotels t
                        SET 
                           hotel_name = u.hotel_name,
                           bnovo_id = u.bnovo_id,
                           synonyms = u.synonyms
                    FROM operate.hotels s
                        INNER JOIN temp_hotels_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.hotel_name, s.bnovo_id, s.synonyms
                        EXCEPT
                        SELECT u.hotel_name, u.bnovo_id, u.synonyms
                        ) and t.id = s.id;

                    INSERT INTO operate.hotels (hotel_name, bnovo_id, synonyms)
                    SELECT     
                        hotel_name,
                        bnovo_id,
                        synonyms
                    FROM temp_hotels_table_update
                    WHERE
                        id is NULL;
                    """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex        

def put_devices(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0
                  and len(str(newrow[2])) == 0):
                  continue
              

              list_of_args.append("({}, {}, {})"
                  .format(my_utility.num_to_query_substr(newrow[0]), #id
                  my_utility.num_to_query_substr(newrow[1]), #hotel_id
                  my_utility.num_to_query_substr(newrow[2]))) #source_id      
                  

          if len(list_of_args) > 0:
            
            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO operate.devices
                                (id, hotel_id, source_id)
                              VALUES """ + args_str + """
                                on conflict (id) do update
                                    set 
                                        hotel_id = EXCLUDED.hotel_id,
                                        source_id = EXCLUDED.source_id
                              """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex     

def put_employees(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0 
                  and len(str(newrow[2])) == 0 
                  and len(str(newrow[3])) == 0):
                  continue
              
              list_of_args.append("({}, '{}', '{}', '{}')"
                  .format(my_utility.num_to_query_substr(newrow[0]), #id
                  newrow[1],                                         #last_name
                  newrow[2],                                         #first_name
                  newrow[3]))                                        #name_in_db
                  

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_employees_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_employees_table_update AS SELECT * FROM operate.employees WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_employees_table_update
                                (id, last_name, first_name, name_in_db)
                              VALUES """ + args_str)
            

            cursor.execute("""
                    
                    UPDATE operate.employees t
                        SET last_name = u.last_name,
                            first_name = u.first_name,
                            name_in_db = u.name_in_db
                    FROM operate.employees s
                        INNER JOIN temp_employees_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.last_name, s.first_name, s.name_in_db
                        EXCEPT
                        SELECT u.last_name, u.first_name, u.name_in_db
                        ) and t.id = s.id;

                    INSERT INTO operate.employees (last_name, first_name, name_in_db)
                    SELECT     
                        last_name, 
                        first_name, 
                        name_in_db
                    FROM temp_employees_table_update
                    WHERE
                        id is NULL;
                    """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex


def put_report_items(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:
              
                        # ri.id,
                        # ri.item_name,
                        # ri.order_count, 
                        # ri.empl_id,
                        # em.name_in_db,
                        # ri.source_id,
                        # so.source_name 

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0 
                  and len(str(newrow[2])) == 0 
                  and len(str(newrow[3])) == 0 
                  and len(str(newrow[5])) == 0):
                  continue
              
              list_of_args.append("({}, '{}', {}, {}, {})"
                  .format(my_utility.num_to_query_substr(newrow[0]), #id
                  newrow[1],                                         #item_name
                  my_utility.num_to_query_substr(newrow[2]),         #order_count
                  my_utility.num_to_query_substr(newrow[3]),         #empl_id
                  my_utility.num_to_query_substr(newrow[5])))        #source_id

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_items_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_items_table_update AS SELECT * FROM operate.report_items WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_items_table_update
                                (id, item_name, order_count, empl_id, source_id)
                              VALUES """ + args_str)
            

            cursor.execute("""
                    
                    UPDATE operate.report_items t
                        SET item_name = u.item_name,
                            order_count = u.order_count,
                            empl_id = u.empl_id,
                            source_id = u.source_id
                    FROM operate.report_items s
                        INNER JOIN temp_items_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.item_name, s.order_count, s.empl_id, s.source_id
                        EXCEPT
                        SELECT u.item_name, u.order_count, u.empl_id, u.source_id
                        ) and t.id = s.id;

                    INSERT INTO operate.report_items (item_name, order_count, empl_id, source_id)
                    SELECT     
                        item_name, 
                        order_count, 
                        empl_id, 
                        source_id
                    FROM temp_items_table_update
                    WHERE
                        id is NULL;
                    """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex


def put_report_items_setings(datastrings: list):

    global connection

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:
              
                        # rs.source_id,
                        # so.source_name,  
                        # rs.report_item_id,
                        # ri.item_name,
                        # rs.view_permission

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[2])) == 0 
                  and len(str(newrow[4])) == 0):
                  continue
              
              list_of_args.append("({}, {}, {})"
                  .format(my_utility.num_to_query_substr(newrow[0]), #source_id
                  my_utility.num_to_query_substr(newrow[2]),         #report_item_id
                  newrow[4]))                                        #view_permission
                  

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_setings_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_setings_table_update AS SELECT * FROM operate.report_items_setings WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_setings_table_update
                                (source_id, report_item_id, view_permission)
                              VALUES """ + args_str)
            

            cursor.execute("""
                    
                    UPDATE operate.report_items_setings t
                        SET view_permission = u.view_permission
                    FROM operate.report_items_setings s
                        INNER JOIN temp_setings_table_update u ON u.source_id = s.source_id AND u.report_item_id = s.report_item_id
                    WHERE EXISTS (
                        SELECT s.view_permission
                        EXCEPT
                        SELECT u.view_permission
                        ) and t.source_id = s.source_id AND t.report_item_id = s.report_item_id;
                    """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex


@app.get("/dict_operate")
def get_dict() -> dict:
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    dict_name = app.current_event.get_query_string_value(name="dict_name", default_value="")

    result = {}

    if dict_name == 'sources':
        result["data"] = get_sources()

    if dict_name == 'hotels':
        result["data"] = get_hotels()

    if dict_name == 'devices':
        result["data"] = get_devices()

    if dict_name == 'employees':
        result["data"] = get_employees()

    if dict_name == 'report_items':
        result["data"] = get_report_items()

    if dict_name == 'report_items_setings':
        result["data"] = get_report_settings(source_id)

    return my_utility.get_response(result)

@app.get("/booking_problems")
def get_booking_problems() -> dict:

    result = {}

    result["data"] = get_booking_problems_state()

    return my_utility.get_response(result)  

@app.post("/booking_problems")
def put_booking_problems() -> dict:
    datastrings = app.current_event.json_body

    put_booking_problems_state(datastrings)

@app.get("/cancel_bookings")
def get_cancel_bookings() -> dict:

    result = {}

    result["data"] = get_canceled_booking_state()

    return my_utility.get_response(result) 

@app.get("/users_sales")
def get_cancel_bookings() -> dict:

    result = {}

    result["data"] = get_users_sales_state()

    return my_utility.get_response(result)

@app.get("/company-act/<inn>/<date_month>")
def get_company_acts(inn: str, date_month: str) -> dict:
    result = {}

    result["data"] = get_company_acts_state(inn, date_month)

    return my_utility.get_response(result) 


@app.post("/dict_operate")
def put_dict() -> dict:
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    dict_name = app.current_event.get_query_string_value(name="dict_name", default_value="")

    datastrings = app.current_event.json_body

    if dict_name == 'sources':
        put_sources(datastrings)

    if dict_name == 'hotels':
        put_hotels(datastrings)

    if dict_name == 'devices':
        put_devices(datastrings)

    if dict_name == 'employees':
        put_employees(datastrings)

    if dict_name == 'report_items':
        put_report_items(datastrings)

    if dict_name == 'report_items_setings':
        put_report_items_setings(datastrings)

def lambda_handler(event, context):
    print({'event': event, 'context': context})

    global connection

    result = {}
    try:
        result = app.resolve(event, context)
    except Exception as er:
        result["DataError"] = str(er)

        connection.close()
        connection = my_utility.get_db_connection()

    return result