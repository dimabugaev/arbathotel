import psycopg2
import json
import re
#from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver

import boto3
from datetime import date, timedelta



secret_name = "dev-rds-instance"
region_name = "eu-central-1"

session = boto3.session.Session(profile_name='arbathotelserviceterraformuser')  #for debugg
#session = boto3.session.Session()
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

def get_date_from_int_excel(int_excel: int) -> str:
    result = "NULL"
    if int is not None:
        result = "TO_DATE('" + str(date.fromisoformat('1899-12-30') + + timedelta(days = int_excel)) + "','YYYY-mm-DD')"    
    
    return result

def num_to_query_substr(id: any, result_if_null = "NULL") -> str: 
    result = result_if_null
    if id is not None:
        if isinstance(id, str):
            result = result_if_null    
        else:
          result = id
    return result

    

@app.get("/string")
def get_report_strings():
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    date_start = app.current_event.get_query_string_value(name="date_start", default_value="")
    date_end = app.current_event.get_query_string_value(name="date_end", default_value="")
    mode = app.current_event.get_query_string_value(name="mode", default_value='0')
    
    if not mode.isdigit(): 
        mode = 0
    else: 
        mode = int(mode)


    cursor = connection.cursor()
    cursor.execute("""select 
                          so.id as found_source_id
                        from operate.sources so 
                        where so.source_external_key = %(source_key)s
                        limit 1""", {'source_key': source_id})
    
    if cursor.rowcount < 1:
        return get_response({'FormatError': source_id})

    found_source_id = cursor.fetchone()[0]

    print(found_source_id)

    cursor.execute("""SELECT 
                        --st.id,  
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
                        st.source_id = %(source_id)s and 
                        ((st.applyed is null and %(mode)s = 0) or 
                          (st.applyed is not null and %(mode)s = 1) or 
                          (%(mode)s = 2))""", {'source_id': found_source_id, 'mode': mode})
    

    bodyDict = {}
    bodyDict["report_strings"] = cursor.fetchall()
    return get_response(bodyDict)

@app.post("/string")
def put_operate_report_strings():
    
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    newstrings = app.current_event.json_body

    cursor = connection.cursor()


    cursor.execute("""select 
                          so.id as found_source_id
                        from operate.sources so 
                        where so.source_external_key = %(source_key)s
                        limit 1""", {'source_key': source_id})
    
    if cursor.rowcount < 1:
        return get_response({'FormatError': source_id})

    found_source_id = cursor.fetchone()[0]

    
    cursor.execute("""delete 
                        from operate.report_strings 
                      where
                        applyed is null and source_id = %(source_id)s""", {'source_id': found_source_id})          

    #args_str = ','.join(cursor.mogrify('%d, %s, %s, %s, %s, %s, %s', source_id, newrow) for newrow in newstrings)
    args_str = ','.join(("({}, {}, {}, {}, {}, {}, '{}')"
      .format(found_source_id, num_to_query_substr(newrow[7]), 
              get_date_from_int_excel(newrow[0]), 
              num_to_query_substr(newrow[8]), 
              num_to_query_substr(newrow[1], 0), 
              num_to_query_substr(newrow[2], 0), 
              newrow[6])) for newrow in newstrings)



    #print("""INSERT INTO operate.report_strings
    #                    (source_id, report_item_id, report_date, hotel_id, sum_income, sum_spend, string_comment)
    #                  VALUES """ + args_str)
    try:
      cursor.execute("""INSERT INTO operate.report_strings
                          (source_id, report_item_id, report_date, hotel_id, sum_income, sum_spend, string_comment)
                        VALUES """ + args_str)
      connection.commit()
    except:
      connection.rollback()
      raise      

    



@app.get("/dict")
def get_hotels_and_report_ivents() -> dict:
    source_id = app.current_event.get_query_string_value(name="source_id", default_value="")

    if re.match('\S+', source_id) is None: # bad string
        return get_response({'FormatError': source_id})


    cursor = connection.cursor()
    
    bodyDict = {}

    cursor.execute("""with find_source as (
                        select 
                          so.id 
                        from operate.sources so 
                        where so.source_external_key = %(source_key)s
                        limit 1
                      )
                      select 
                          ho.id, 
                          ho.hotel_name 
                      from 
                          operate.hotels ho inner join find_source so on (true)""", {'source_key': source_id})
    
    #rows = cursor.fetchall()
    bodyDict["hotels"] = cursor.fetchall()
    
    cursor.execute("""with approve_items as (
                        select
                          ris.report_item_id as id 
                        from 
                          operate.report_items_setings ris
                        where 
                          ris.source_id in 
                            (select id from operate.sources so where so.source_external_key = %(source_key)s)
                          and ris.view_permission = TRUE
                      )
                      select 
                        ri.id,
                        ri.item_name 
                      from 
                        operate.report_items ri inner join
                          approve_items ap on (ri.id = ap.id)""", {'source_key': source_id})
                        
    bodyDict["report_items"] = cursor.fetchall()
    
    cursor.close()

    return get_response(bodyDict)

@app.post("/close")
def current_string_to_histirical():
    print(app.current_event.query_string_parameters)

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
