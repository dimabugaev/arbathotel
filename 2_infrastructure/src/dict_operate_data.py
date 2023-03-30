import psycopg2
import json
import re
#from aws_lambda_powertools import Logger, Tracer
from aws_lambda_powertools.event_handler import APIGatewayHttpResolver

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

@app.get("/dict_operate")
def current_string_to_histirical():
    result = {}

    result["test"] = "hello!!! it's work"

    return get_response(result)   

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