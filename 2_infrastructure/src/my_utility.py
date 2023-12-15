import psycopg2
import boto3
import json
import requests
import os
from datetime import date, timedelta

#email reports data
def get_email_and_storage_data():
    secret_name = os.environ['REPORT_SECRET']
    region_name = "eu-central-1"    

    #session = boto3.session.Session(profile_name='arbathotelserviceterraformuser')  #for debugg
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    secret_value_dict = json.loads(client.get_secret_value(SecretId=secret_name)['SecretString'])
    s3client = session.client(service_name='s3')
    secret_value_dict['s3client'] = s3client
    return secret_value_dict

#ESC get params to run
def get_params_to_run_ecs_task_dbt() -> dict:
    secret_name = os.environ['RDS_SECRET']
    region_name = "eu-central-1"    

    #session = boto3.session.Session(profile_name='arbathotelserviceterraformuser')  #for debugg
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    secret_value_dict = json.loads(client.get_secret_value(SecretId=secret_name)['SecretString'])

    secret_name = os.environ['ECS_SECRET']
    secret_value_dict.update(json.loads(client.get_secret_value(SecretId=secret_name)['SecretString']))

    return secret_value_dict

#DB
#connection to data base
def get_db_connection():
    secret_name = os.environ['RDS_SECRET']
    region_name = "eu-central-1"

    #session = boto3.session.Session(profile_name='arbathotelserviceterraformuser')  #for debugg
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    secret_value_dict = json.loads(client.get_secret_value(SecretId=secret_name)['SecretString'])

    endpoint = secret_value_dict['host']
    username = secret_value_dict['username']
    password = secret_value_dict['password']
    database_name = secret_value_dict['dbname']

    return psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)


#map_of_collumn - keys - name of SQL table columns, values - name of data list items keys DB Table must have source_id
def update_dim_raw(db_connection, data_list: list, name_of_data: str, name_of_table: str, map_of_collumn: dict, source_id: int = None):
    
    temp_table_name = "temp_"+name_of_data+"_table_update"

    cursor = db_connection.cursor()

    cursor.execute("DROP TABLE IF EXISTS " + temp_table_name)
    cursor.execute("CREATE TEMP TABLE " + temp_table_name + " AS SELECT * FROM " + name_of_table + " WHERE false")

    list_of_params = []

    substring_of_colunm = "(source_id"
    substring_of_values = "(%s"
    substring_of_colunm_i = "i.source_id"

    update_colunm_text = "SET date_update = current_timestamp"
    where_condition_source = "SELECT s.source_id"
    where_condition_update = "SELECT u.source_id"

    for k in map_of_collumn.keys():
        list_of_params.append(k)
        substring_of_colunm += ', ' + k
        substring_of_values += ', %s'

        update_colunm_text += ', ' + k + ' = u.' + k
        where_condition_source += ', s.' + k
        where_condition_update += ', u.' + k
        substring_of_colunm_i += ', i.' + k        

    substring_of_colunm += ')' 
    substring_of_values += ')'

    query_populate_temp = "INSERT INTO " + temp_table_name + " " + substring_of_colunm + " VALUES " + substring_of_values

    for row in data_list:
        list_of_string_data = []
        list_of_string_data.append(source_id)
        for value in list_of_params:
            list_of_string_data.append(row.get(map_of_collumn[value], None))

        cursor.execute(query_populate_temp, tuple(list_of_string_data))

    
    final_query = "UPDATE " + name_of_table + " t " + update_colunm_text + " FROM " + name_of_table + " s "
    final_query += "INNER JOIN " + temp_table_name + " u ON u.id = s.id AND coalesce(u.source_id, 0) = coalesce(s.source_id, 0) "
    final_query += "WHERE EXISTS (" + where_condition_source + " EXCEPT " + where_condition_update + ") and t.id = s.id and coalesce(t.source_id, 0) = coalesce(s.source_id, 0); "
    final_query += "INSERT INTO " + name_of_table + " " + substring_of_colunm + " SELECT " + substring_of_colunm_i + " FROM " + temp_table_name + " i "
    final_query += "LEFT JOIN " + name_of_table + " s ON coalesce(i.source_id, 0) = coalesce(s.source_id, 0) AND i.id = s.id WHERE s.id is NULL;" 

    #print(final_query)

    cursor.execute(final_query)
    db_connection.commit()
    cursor.close()  

#JSON and type service 
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

def get_begin_month_by_date(date_period: date) -> date:
    return date(date_period.year, date_period.month, 1)


def get_end_month_by_date(date_period: date) -> date:
    next_month = date_period.replace(day=28) + timedelta(days=4)
    next_month = next_month - timedelta(days=next_month.day)
    return next_month

#BNOVO!!
#connection to bnovo
def get_bnovo_session_by_source_id(connection, source_id):
    cred = get_binovo_cred(connection, source_id)
    return get_autorized_http_session_bnovo(cred['username'], cred['password'])


def get_autorized_http_session_bnovo(username, password):
    session = requests.Session()
    url = "https://online.bnovo.ru"

    # Set the request body
    body = {
        "username": username,
        "password": password
    }

    session.headers.update({
        "Content-Type": "application/json",
        "Accept": "application/json" 
    })

    # Make the POST request using the session
    with session.post(url, data=json.dumps(body)) as response:
        # Check if the request was successful
        if response.status_code == 200:
            print("Authorization SID for {}: {}".format(username, session.cookies.get('SID')))
        else:
            print("Failed to get authorization token for {}. Status code: {}".format(username, response.status_code))
    
    return session

def get_http_session_bnovo_by_sid(sid: str):
    session = requests.Session()
    session.headers.update({
        "Content-Type": "application/json",
        "Accept": "application/json" 
    })

    session.cookies.update({
        "SID": sid    
    })
    return session

def get_binovo_cred(connection, source_id):
    cursor = connection.cursor()

    res = {'username': None, 'password': None}

    cursor.execute("""SELECT 
                        so.source_username, 
                        so.source_password,
                        so.id 
                      FROM operate.sources so
                      WHERE 
                        so.source_type = 2
                        AND so.id = %(source_id)s
                        AND coalesce(so.source_username, '') <> ''
                        AND coalesce(so.source_password, '') <> '' """, {'source_id': source_id})
    
    if cursor.rowcount > 0:
        my_cred = cursor.fetchone()
        res['username'] = my_cred[0]
        res['password'] = my_cred[1]

    cursor.close()

    return res    