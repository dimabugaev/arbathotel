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
    #url = "https://business.tinkoff.ru/openapi/sandbox/api/v1/bank-statement?accountNumber={}&from={}&till={}&cursor={}"
    url = "https://business.tinkoff.ru/openapi/api/v1/bank-statement?accountNumber={}&from={}&till={}&cursor={}"
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

def update_payments(connection, source_id:int, data_for_update:dict):

    payments_map = {
            "period_month": "periodMonth",
            "id": "operationId",
            "date": "date",
            "amount": "amount",
            "draw_date": "drawDate",
            "payer_name": "payerName",
            "payer_inn": "payerInn",
            "payer_account": "payerAccount",
            "payer_corr_account": "payerCorrAccount",
            "payer_bic": "payerBic",
            "payer_bank": "payerBank",
            "charge_date": "chargeDate",
            "recipient": "recipient",
            "recipient_inn": "recipientInn",
            "recipient_account": "recipientAccount",
            "recipient_corr_account": "recipientCorrAccount",
            "recipient_bic": "recipientBic",
            "recipient_bank": "recipientBank",
            "operation_type": "operationType",
            "payment_purpose": "paymentPurpose",
            "creator_status": "creatorStatus",
            "recipient_kpp": "recipientKpp",
            "execution_order": "executionOrder"
        }
    
    load_data = data_for_update['operation']
    for data_row in load_data:
        data_row['periodMonth'] = my_utility.get_begin_month_by_date(datetime.strptime(data_row['date'], '%Y-%m-%d'))    
    
    my_utility.update_dim_raw(connection, load_data, "payments", "banks_raw.tinkoff_payments", payments_map, source_id)

    next_cursor = data_for_update.get("cursor")
    if next_cursor is None:
        next_cursor = ''     

    return next_cursor


def export_account_data_from_tinkoff_to_rds(source_id:int, account:str, token:str, datefrom: date, dateto: date):
    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()

        next_cursor = ''
        while True:
            #print(get_accounts(token))
            
            payments = get_payments(token, account, datefrom, dateto, next_cursor)
            next_cursor = update_payments(conn, source_id, payments)
            #payment_ids.extend(payments['operationId'])
            #print(payments)
            if next_cursor == '':
                break    

        cursor.close()

def lambda_handler(event, context):

    source_id = event['source_id']
    account = event['account']
    token = event['token']
    datefrom = datetime.strptime(event['datefrom'], '%d.%m.%Y')
    dateto = datetime.strptime(event['dateto'], '%d.%m.%Y')

    export_account_data_from_tinkoff_to_rds(source_id, account, token, datefrom, dateto)
