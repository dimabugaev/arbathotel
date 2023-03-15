import psycopg2
import json
import re
#from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver

import boto3


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
    #response_obj['body'] = json.dumps(body)
    response_obj['body'] = body

    return response_obj

@app.get("/string")
def get_report_strings():
    source_id = app.current_event.query_string_parameters.get("source_id")
    date_start = app.current_event.query_string_parameters.get("date_start")
    date_end = app.current_event.query_string_parameters.get("date_end")
    mode = app.current_event.query_string_parameters.get("mode")
    

    if mode is None or not mode.isdigit(): 
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

    cursor.execute("""SELECT 
                        id,  
                        report_item_id, 
                        created, 
                        applyed, 
                        report_date, 
                        hotel_id, 
                        sum_income, 
                        sum_spend, 
                        string_comment
                      FROM operate.report_strings
                      where 
                        source_id = %(source_id)s and 
                        ((applyed is null and %(mode)d = 0) or 
                          (applyed is not null and %(mode)d = 1) or 
                          (%(mode)d = 2))""", {'source_id': found_source_id, 'mode': mode})
    
    bodyDict = {}
    bodyDict["report_strings"] = cursor.fetchall()
    return get_response(bodyDict)

@app.post("/string")
def put_operate_report_strings():
    source_id = app.current_event.query_string_parameters.get("source_id")
    newstrings = app.current_event.body

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

    args_str = ','.join(cursor.mogrify('%d, %s, %s, %s, %s, %s, %s', source_id, newrow) for newrow in newstrings)

    cursor.execute("""INSERT INTO operate.report_strings
                        (source_id, report_item_id, report_date, hotel_id, sum_income, sum_spend, string_comment)
                      VALUES """ + args_str)
    
    connection.commit()



@app.get("/dict")
def get_hotels_and_report_ivents() -> dict:
    source_id = app.current_event.query_string_parameters.get("source_id")

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
    return app.resolve(event, context)
