import my_utility
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver
from typing import Any


import json
import requests

#from datetime import date, timedelta, datetime


connection = my_utility.get_db_connection()

app = APIGatewayHttpResolver()

def get_report(session, source_id: int, body):

    items = {}
    url = "https://online.bnovo.ru/reports/adr"

    print(url)

    with session.post(url, data=json.dumps(body)) as response:
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print(response.headers)

    raise ValueError('-- Faild to get request -- ' + url)

def get_report_users(session, source_id: int, body):

    items = {}
    url = "https://online.bnovo.ru/reports/users"

    print(url)

    with session.post(url, data=json.dumps(body)) as response:
        if response.status_code == 200:
            return json.loads(response.text)
        else:
            print(response.headers)

    raise ValueError('-- Faild to get request -- ' + url)

@app.post("/report-adr/<source_id>")
def put_dict(source_id: str) -> dict:
    #source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    #dict_name = app.current_event.get_query_string_value(name="dict_name", default_value="")

    datastrings = app.current_event.json_body

    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()


        http_session = None

        
        session_cred = my_utility.get_binovo_cred(conn, source_id)
        if session_cred['username'] is None:
            print('Credentions is absent!!')
            return False
        http_session = my_utility.get_autorized_http_session_bnovo(session_cred['username'], session_cred['password'])
        

        result = get_report(http_session, int(source_id), datastrings)

        cursor.close()
        return result
    
@app.post("/report-users/<source_id>")
def put_dict(source_id: str) -> dict:
    #source_id = app.current_event.get_query_string_value(name="source_id", default_value="")
    #dict_name = app.current_event.get_query_string_value(name="dict_name", default_value="")

    datastrings = app.current_event.json_body

    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()


        http_session = None

        
        session_cred = my_utility.get_binovo_cred(conn, source_id)
        if session_cred['username'] is None:
            print('Credentions is absent!!')
            return False
        http_session = my_utility.get_autorized_http_session_bnovo(session_cred['username'], session_cred['password'])
        

        result = get_report_users(http_session, int(source_id), datastrings)

        cursor.close()
        return result

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