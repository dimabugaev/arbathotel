from datetime import date, datetime
import my_utility
import json
import requests

def get_accounts(token):

    session = requests.Session()
    url = "https://business.tinkoff.ru/openapi/sandbox/api/v1/bank-accounts"
    #url = "https://business.tinkoff.ru/openapi/api/v1/bank-statement?accountNumber={}&from={}&till={}&cursor={}"

    session.headers.update({
        'Authorization': f'Bearer {token}',
        "Content-Type": "application/json",
        "Accept": "application/json" 
    })


    accounts = {}

    with session.get(url) as response:
        accounts = json.loads(response.text) 

    return accounts

def get_payments(token, account, datefrom, dateto, cursor = ''):

    session = requests.Session()
    url = "https://business.tinkoff.ru/openapi/sandbox/api/v1/bank-statement?accountNumber={}&from={}&till={}&cursor={}"
    #url = "https://business.tinkoff.ru/openapi/api/v1/bank-statement?accountNumber={}&from={}&till={}&cursor={}"
    url = url.format(
        account,
        datefrom.strftime('%Y-%m-%d'),
        dateto.strftime('%Y-%m-%d'),
        cursor
    ) 

    session.headers.update({
        'Authorization': f'Bearer {token}',
        "Content-Type": "application/json",
        "Accept": "application/json" 
    })


    payments = {}

    with session.get(url) as response:
        payments = json.loads(response.text) 

    return payments

def export_account_data_from_tinkoff_to_rds(source_id:int, account:str, token:str, datefrom: date, dateto: date):
    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()

        while True:
            print(get_accounts(token))
            payments = get_payments(token, account, datefrom, dateto)
            print(payments)
            break    

        cursor.close()

def lambda_handler(event, context):

    source_id = event['source_id']
    account = event['account']
    token = event['token']
    datefrom = datetime.strptime(event['datefrom'], '%d.%m.%Y')
    dateto = datetime.strptime(event['dateto'], '%d.%m.%Y')

    export_account_data_from_tinkoff_to_rds(source_id, account, token, datefrom, dateto)
