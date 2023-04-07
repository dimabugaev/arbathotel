import psycopg2
import json
import re
#from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver
from typing import Any

import boto3
from datetime import date, timedelta, datetime

secret_name = "dev-rds-instance"
region_name = "eu-central-1"

#session = boto3.session.Session(profile_name='arbathotelserviceterraformuser')  #for debugg
session = boto3.session.Session()
client = session.client(service_name='secretsmanager', region_name=region_name)
secret_value_dict = json.loads(client.get_secret_value(SecretId=secret_name)['SecretString'])

endpoint = secret_value_dict['host']
username = secret_value_dict['username']
password = secret_value_dict['password']
database_name = secret_value_dict['dbname']

connection = psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)
#tracer = Tracer()
#logger = Logger()
app = APIGatewayHttpResolver()


def get_response(body: dict = {}) -> dict:
    response_obj = {}
    response_obj["statusCode"] = 200
    response_obj["headers"] = {}
    response_obj["headers"]["Content-Type"] = 'application/json'
    response_obj['body'] = json.loads(json.dumps(body, indent=4, default=str))

    return response_obj

def num_to_query_substr(id: any, result_if_null = "NULL") -> str: 
    result = result_if_null
    if id is not None:
        if isinstance(id, str):
            result = result_if_null    
        else:
          result = id
    return result

def get_sources() -> list:
    cursor = connection.cursor()
    
    cursor.execute("""select 
                        s.id,
                        s.source_name,
                        s.source_type, 
                        s.source_external_key,
                        s.source_income_debt::FLOAT 
                      from 
                        operate.sources s
                      order by
                        s.id""")
    
    return cursor.fetchall()
                            
def get_hotels() -> list:
    cursor = connection.cursor()
    
    cursor.execute("""select 
                        h.id,
                        h.hotel_name 
                      from 
                        operate.hotels h
                      order by
                        h.id""")
    
    return cursor.fetchall()

def get_employees() -> list:
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
    if re.match('\S+', source_id) is None: # bad string
        return get_response({'FormatError': source_id})
    
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

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0 
                  and len(str(newrow[2])) == 0 
                  and len(str(newrow[3])) == 0 
                  and len(str(newrow[4])) == 0):
                  continue
              
              list_of_args.append("({}, '{}', {}, '{}', {})"
                  .format(num_to_query_substr(newrow[0]), #id
                  newrow[1],                              #source_name
                  num_to_query_substr(newrow[2]),         #source_type
                  newrow[3],                              #source_external_key
                  num_to_query_substr(newrow[4])))        #source_income_debt

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_source_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_source_table_update AS SELECT * FROM operate.sources WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_source_table_update
                                (id, source_name, source_type, source_external_key, source_income_debt)
                              VALUES """ + args_str)
            

            cursor.execute("""
                    
                    UPDATE operate.sources t
                        SET source_name = u.source_name,
                            source_type = u.source_type,
                            source_external_key = u.source_external_key,
                            source_income_debt = u.source_income_debt
                    FROM operate.sources s
                        INNER JOIN temp_source_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.source_name, s.source_type, s.source_external_key, s.source_income_debt
                        EXCEPT
                        SELECT u.source_name, u.source_type, u.source_external_key, u.source_income_debt
                        ) and t.id = s.id;

                    INSERT INTO operate.sources (source_name, source_type, source_external_key, source_income_debt)
                    SELECT     
                        source_name, 
                        source_type, 
                        source_external_key, 
                        source_income_debt
                    FROM temp_source_table_update
                    WHERE
                        id is NULL;
                    """)


            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex


def put_hotels(datastrings: list):

    if len(datastrings) > 0:
        cursor = connection.cursor()

        try:
          
          list_of_args = []
          for newrow in datastrings:

              if (len(str(newrow[0])) == 0 
                  and len(str(newrow[1])) == 0):
                  continue
              

              list_of_args.append("({}, '{}')"
                  .format(num_to_query_substr(newrow[0]), #id
                  newrow[1]))                             #hotel_name
                  

          if len(list_of_args) > 0:
            cursor.execute("""DROP TABLE IF EXISTS temp_hotels_table_update""")
            cursor.execute("""CREATE TEMP TABLE temp_hotels_table_update AS SELECT * FROM operate.hotels WHERE false""")

            args_str = ','.join(list_of_args)
            cursor.execute("""INSERT INTO temp_hotels_table_update
                                (id, hotel_name)
                              VALUES """ + args_str)
            

            cursor.execute("""                    
                    UPDATE operate.hotels t
                        SET hotel_name = u.hotel_name
                    FROM operate.hotels s
                        INNER JOIN temp_hotels_table_update u ON u.id = s.id
                    WHERE EXISTS (
                        SELECT s.hotel_name
                        EXCEPT
                        SELECT u.hotel_name
                        ) and t.id = s.id;

                    INSERT INTO operate.hotels (hotel_name)
                    SELECT     
                        hotel_name
                    FROM temp_hotels_table_update
                    WHERE
                        id is NULL;
                    """)

            connection.commit()
        except Exception as ex:
          connection.rollback()
          raise ex        


def put_employees(datastrings: list):

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
                  .format(num_to_query_substr(newrow[0]), #id
                  newrow[1],                              #last_name
                  newrow[2],                              #first_name
                  newrow[3]))                             #name_in_db
                  

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
                  .format(num_to_query_substr(newrow[0]), #id
                  newrow[1],                              #item_name
                  num_to_query_substr(newrow[2]),         #order_count
                  num_to_query_substr(newrow[3]),         #empl_id
                  num_to_query_substr(newrow[5])))        #source_id

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
                  .format(num_to_query_substr(newrow[0]), #source_id
                  num_to_query_substr(newrow[2]),         #report_item_id
                  newrow[4]))                             #view_permission
                  

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

    if dict_name == 'employees':
        result["data"] = get_employees()

    if dict_name == 'report_items':
        result["data"] = get_report_items()

    if dict_name == 'report_items_setings':
        result["data"] = get_report_settings(source_id)

    return get_response(result)  


@app.post("/dict_operate")
def put_dict() -> dict:
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    dict_name = app.current_event.get_query_string_value(name="dict_name", default_value="")

    datastrings = app.current_event.json_body

    if dict_name == 'sources':
        put_sources(datastrings)

    if dict_name == 'hotels':
        put_hotels(datastrings)

    if dict_name == 'employees':
        put_employees(datastrings)

    if dict_name == 'report_items':
        put_report_items(datastrings)

    if dict_name == 'report_items_setings':
        put_report_items_setings(datastrings)

def lambda_handler(event, context):
    print({'event': event, 'context': context})

    result = {}
    try:
        result = app.resolve(event, context)
    except Exception as er:
        result["DataError"] = str(er)

        connection.close()
        connection = psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)

    return result