import psycopg2
import json
import re
#from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver


endpoint = 'dev.coxuw68luhb8.eu-central-1.rds.amazonaws.com'
username = 'dev'
password = 'rootroot'
database_name = 'dev_arbathotel'

connection = psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)
#tracer = Tracer()
#logger = Logger()
app = APIGatewayHttpResolver()

def get_response(body: dict = {}) -> dict:
    response_obj = {}
    response_obj["statusCode"] = 200
    response_obj["headers"] = {}
    response_obj["headers"]["Content-Type"] = 'application/json'
    response_obj['body'] = json.dumps(body)

    return response_obj

@app.get("/string")
def get_report_strings():
    print(app.current_event.query_string_parameters)
    source_id = app.current_event.query_string_parameters.get("source_id")
    date_start = app.current_event.query_string_parameters.get("date_start")
    date_end = app.current_event.query_string_parameters.get("date_end")
    mode = app.current_event.query_string_parameters.get("mode")
    
    if mode is None: 
        mode = 0
    #else 
 

@app.post("/string")
def put_operate_report_strings():
    print(app.current_event.query_string_parameters)

@app.get("/dict")
def get_hotels_and_report_ivents() -> dict:
    source_id = app.current_event.query_string_parameters.get("source_id")

    if re.match('\S+', source_id) is None: # bad string
        return get_response({'FormatError': source_id})

    cursor = connection.cursor()
    
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
    
    bodyDict = {}
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
    
    return get_response(bodyDict)

@app.post("/close")
def current_string_to_histirical():
    print(app.current_event.query_string_parameters)

def lambda_handler(event, context):
    print({'event': event, 'context': context})
    return app.resolve(event, context)
