import psycopg2
import boto3
import json
import requests

def get_db_connection():
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

    return psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)


def get_autorized_http_session_bnovo(username, password):
    session = requests.Session()
    url = "https://online.bnovo.ru"

    # Set the request body
    body = {
        "username": username,
        "password": password
    }

    session.headers.update({
        "Content-Type": "application/json"
    })

    # Make the POST request using the session
    with session.post(url, data=json.dumps(body)) as response:
        # Check if the request was successful
        if response.status_code == 200:
            print("Authorization SID for {}: {}".format(username, session.cookies.get('SID')))
        else:
            print("Failed to get authorization token for {}. Status code: {}".format(username, response.status_code))
    
    return session


def export_data_from_bnovo_to_rds():
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""SELECT 
                        so.source_username, 
                        so.source_password 
                      FROM operate.sources so
                      WHERE 
                        so.source_type = 2
                        AND so.source_username is not NULL
                        AND so.source_password is not NULL""")
    
    rows = cursor.fetchall()

    for row in rows:
        get_autorized_http_session_bnovo(row[0], row[1])

    cursor.close()
    conn.close()   


def lambda_handler(event, context):
    export_data_from_bnovo_to_rds()