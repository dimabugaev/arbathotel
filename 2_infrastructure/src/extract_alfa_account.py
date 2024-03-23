from datetime import date, datetime, timedelta
import my_utility
import json
import requests
import os

import ssl
from requests.adapters import HTTPAdapter

#CFG_FILE = '<path_to_cfg>'
secure_hosts = [
  'https://baas.alfabank.ru'
]

class SSLAdapter(HTTPAdapter):
    def __init__(self, certfile, keyfile, password=None, *args, **kwargs):
        self._certfile = certfile
        self._keyfile = keyfile
        self._password = password
        return super(self.__class__, self).__init__(*args, **kwargs)

    def init_poolmanager(self, *args, **kwargs):
        context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH)
        context.load_cert_chain(certfile=self._certfile,
                                keyfile=self._keyfile,
                                password=self._password)
        kwargs['ssl_context'] = context
        return super(self.__class__, self).init_poolmanager(*args, **kwargs)

def get_session(cert_content, key_content, passcode):
    # def get_config():
    #     with open(CFG_FILE) as reader:
    #         return json.load(reader)

    session = requests.Session()
    adapter = SSLAdapter(cert_content, key_content, passcode)

    for host in secure_hosts:
        session.mount(host, adapter)

    session.verify = False
    return session

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

def get_payments(token, account, current_date, next_cursor, certificate, private_key, passcode):

    #session = requests.Session()
    session = get_session(certificate, private_key, passcode)
    url = "https://baas.alfabank.ru/api/statement/transactions?" + next_cursor
    if not next_cursor:
        url = "https://baas.alfabank.ru/api/statement/transactions?accountNumber={}&statementDate={}"
        url = url.format(
            account,
            current_date.strftime('%Y-%m-%d')
        ) 

    session.headers.update({
        'Authorization': f'Bearer {token}',
        "Content-Type": "application/json",
        "Accept": "application/json" 
    })

    payments = {}

    #with session.get(url, cert=(certificate, private_key, '4321')) as response:
    with session.get(url) as response:
        payments = json.loads(response.text) 

    return payments

# {
#     "amount": {
#       "amount": 1.01,
#       "currencyName": "USD"
#     },
#     "amountRub": {
#       "amount": 100.01,
#       "currencyName": "RUR"
#     },
#     "correspondingAccount": "30101810400000000225",
#     "direction": "DEBIT",
#     "documentDate": "2021-10-07",
#     "filial": "АО \"АЛЬФА-БАНК\"",
#     "number": "1843",
#     "operationCode": "01",
#     "operationDate": "2018-12-31T00:00:00Z",
#     "paymentPurpose": "НДС не облагается",
#     "priority": "5",
#     "revaln": "ПК",
#     "uuid": "55daccdf-de87-3879-976c-8b8415c8caf9",
#     "transactionId": "1211206MOCO#DS0000017",
#     "debtorCode": 0,
#     "extendedDebtorCode": 50012008,
#     "curTransfer": {
#       "payerBankCorrAccount": "30101810200000000593",
#       "intermediaryBankOption": "D",
#       "intermediaryBankName": "АО \"АЛЬФА-БАНК\"",
#       "orderingCustomerAccount": "/08251801040004813",
#       "orderingCustomerName": "ООО Радуга",
#       "instructionCode": "instructionCode",
#       "messageType": "103",
#       "exchangeRate": "67,74",
#       "beneficiaryBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "messageOriginator": "SABRRU2P",
#       "receiverCorrespondentAccount": "30101810400000000000",
#       "regulatoryReporting": "/N10/NS/N4/12345678901234567890/N5/12345678901/N6/TP/N7 МS.05.2003/N8/123456789012345/N9/12.05.2003",
#       "beneficiaryBankAccount": "LOYDGB21323",
#       "instructedAmount": "USD70,00",
#       "payeeBankCorrAccount": "30101810200000000593",
#       "transactionRelatedReference": "transactionRelatedReference",
#       "senderCorrespondentName": "CITIBANK N.A. NEW YORK,NY",
#       "senderCorrespondentAccount": "BOTKGB2L",
#       "valueDateCurrencyInterbankSettledAmount": "130824EUR5447,34",
#       "senderCorrespondentOption": "D",
#       "intermediaryBankAccount": "COBADEFF",
#       "payerInn": "7728168971",
#       "senderToReceiverInformation": "/NZP/OT 15.03.2009. NDS NE OBLAGAETSYA",
#       "receiverCorrespondentName": "JSC ROSSELKHOZBANK 3, GAGARINSKY PEREULOK MOSCOW RUSSIAN FEDERATION",
#       "payeeBankBic": "9611925",
#       "senderCharges": "USD7,03",
#       "payeeKpp": "770801001",
#       "payeeAccount": "40802810401300015422",
#       "bankOperationCode": "CRED",
#       "transactionTypeCode": "S01",
#       "payeeName": "Наименование получателя",
#       "messageReceiveTime": "15-05-27 13:21",
#       "messageDestinator": "LAPBLV2X",
#       "messageIdentifier": "S000013082900014",
#       "beneficiaryCustomerName": "ООО Ромашка",
#       "payerName": "Гаврилов Добрыня Петрович",
#       "urgent": "URGENT",
#       "orderingInstitutionName": "АО \"АЛЬФА-БАНК\"",
#       "receiverCorrespondentOption": "D",
#       "orderingInstitutionAccount": "ABOCBNBJ080",
#       "messageSendTime": "15-05-27 13:21",
#       "orderingCustomerOption": "K",
#       "detailsOfCharges": "OUR",
#       "transactionReferenceNumber": 69528,
#       "payerKpp": "770801001",
#       "payerBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "orderingInstitutionOption": "D",
#       "payerAccount": "40802810401300015422",
#       "payeeBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "beneficiaryBankOption": "D",
#       "remittanceInformation": "PAYMENT ACC AGREEMENT 1 DD 29.11.2018 FOR WATCHES",
#       "beneficiaryCustomerAccount": "/40702810701300000761",
#       "payerBankBic": "044525593",
#       "payeeInn": "7728168971",
#       "receiverCharges": "receiverCharges"
#     },
#     "swiftTransfer": {
#       "bankOperationCode": "CRED",
#       "intermediaryBankOption": "D",
#       "intermediaryBankName": "АО \"АЛЬФА-БАНК\"",
#       "orderingCustomerAccount": "/08251801040004813",
#       "orderingCustomerName": "ООО Радуга",
#       "transactionTypeCode": "S01",
#       "instructionCode": "instructionCode",
#       "messageReceiveTime": "15-05-27 13:21",
#       "messageDestinator": "LAPBLV2X",
#       "messageType": "103",
#       "exchangeRate": "67,74",
#       "beneficiaryBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "messageIdentifier": "S000013082900014",
#       "messageOriginator": "SABRRU2P",
#       "receiverCorrespondentAccount": "30101810400000000000",
#       "regulatoryReporting": "/N10/NS/N4/12345678901234567890/N5/12345678901/N6/TP/N7 МS.05.2003/N8/123456789012345/N9/12.05.2003",
#       "beneficiaryBankAccount": "LOYDGB21323",
#       "beneficiaryCustomerName": "ООО Ромашка",
#       "instructedAmount": "USD70,00",
#       "transactionRelatedReference": "transactionRelatedReference",
#       "urgent": "URGENT",
#       "orderingInstitutionName": "АО \"АЛЬФА-БАНК\"",
#       "receiverCorrespondentOption": "D",
#       "senderCorrespondentName": "CITIBANK N.A. NEW YORK,NY",
#       "orderingInstitutionAccount": "ABOCBNBJ080",
#       "senderCorrespondentAccount": "BOTKGB2L",
#       "valueDateCurrencyInterbankSettledAmount": "130824EUR5447,34",
#       "senderCorrespondentOption": "D",
#       "messageSendTime": "15-05-27 13:21",
#       "orderingCustomerOption": "K",
#       "detailsOfCharges": "OUR",
#       "intermediaryBankAccount": "COBADEFF",
#       "transactionReferenceNumber": 69528,
#       "orderingInstitutionOption": "D",
#       "senderToReceiverInformation": "/NZP/OT 15.03.2009. NDS NE OBLAGAETSYA",
#       "receiverCorrespondentName": "JSC ROSSELKHOZBANK 3, GAGARINSKY PEREULOK MOSCOW RUSSIAN FEDERATION",
#       "beneficiaryBankOption": "D",
#       "remittanceInformation": "PAYMENT ACC AGREEMENT 1 DD 29.11.2018 FOR WATCHES",
#       "beneficiaryCustomerAccount": "/40702810701300000761",
#       "senderCharges": "USD7,03",
#       "receiverCharges": "receiverCharges"
#     },
#     "rurTransfer": {
#       "payerBankCorrAccount": "30101810200000000593",
#       "departmentalInfo": {
#         "drawerStatus101": "1",
#         "oktmo": "11605000",
#         "kbk": "39210202010061000160",
#         "taxPeriod107": "МС.03.2016",
#         "docNumber108": "123",
#         "reasonCode106": "ТП",
#         "docDate109": "31.12.2018",
#         "uip": "32221003200126505006",
#         "paymentKind110": "1"
#       },
#       "payerKpp": "770801001",
#       "receiptDate": "2018-12-31",
#       "deliveryKind": "электронно",
#       "payerBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "payerInn": "7728168971",
#       "valueDate": "2018-12-31",
#       "cartInfo": {
#         "documentCode": "documentCode",
#         "documentDate": "2019-10-19T06:33:47.923Z",
#         "restAmount": "restAmount",
#         "documentNumber": "documentNumber",
#         "documentContent": "documentContent",
#         "paymentNumber": "paymentNumber"
#       },
#       "payerAccount": "40802810401300015422",
#       "payeeName": "Наименование получателя",
#       "payeeBankName": "АО \\\"АЛЬФА-БАНК\\\"",
#       "payeeBankBic": "9611925",
#       "payerBankBic": "044525593",
#       "purposeCode": "1",
#       "payeeInn": "7728168971",
#       "payerName": "Гаврилов Добрыня Петрович",
#       "payeeBankCorrAccount": "30101810200000000593",
#       "payeeKpp": "770801001",
#       "payeeAccount": "40802810401300015422",
#       "payingCondition": "payingCondition"
#     }
#   }

def get_payments_for_update(page_data: dict) -> dict:
    
    if page_data:
        for transaction in page_data:
            transaction["period_month"] = my_utility.get_begin_month_by_date(datetime.strptime(transaction['documentDate'], '%Y-%m-%d'))
            transaction["amount_amount"] = transaction["amount"].get("amount")
            transaction["amount_currency_name"] = transaction["amount"].get("currencyName")
            transaction["amount_rub_amount"] = transaction["amountRub"].get("amount")
            transaction["amount_rub_currency_name"] = transaction["amountRub"].get("currencyName")

            transaction["delivery_kind"] = transaction["rurTransfer"].get("deliveryKind")
            transaction["rur_payee_account"] = transaction["rurTransfer"].get("deliveryKind")
            transaction["rur_payee_bank_bic"] = transaction["rurTransfer"].get("payeeBankBic")
            transaction["rur_payee_bank_corr_account"] = transaction["rurTransfer"].get("payeeBankCorrAccount")
            transaction["rur_payee_bank_name"] = transaction["rurTransfer"].get("payeeBankName")
            transaction["rur_payee_inn"] = transaction["rurTransfer"].get("payeeInn")
            transaction["rur_payee_kpp"] = transaction["rurTransfer"].get("payeeKpp")
            transaction["rur_payee_name"] = transaction["rurTransfer"].get("payeeName")
            transaction["rur_payer_account"] = transaction["rurTransfer"].get("payerAccount")
            transaction["rur_payer_bank_bic"] = transaction["rurTransfer"].get("payerBankBic")
            transaction["rur_payer_bank_corr_account"] = transaction["rurTransfer"].get("payerBankCorrAccount")
            transaction["rur_payer_bank_name"] = transaction["rurTransfer"].get("payerBankName")
            transaction["rur_payer_inn"] = transaction["rurTransfer"].get("payerInn")
            transaction["rur_payer_kpp"] = transaction["rurTransfer"].get("payerKpp")
            transaction["rur_payer_name"] = transaction["rurTransfer"].get("payerName")
            transaction["rur_paying_condition"] = transaction["rurTransfer"].get("payingCondition")
            transaction["rur_purpose_code"] = transaction["rurTransfer"].get("purposeCode")
            transaction["rur_receipt_date"] = transaction["rurTransfer"].get("receiptDate")
            transaction["rur_value_date"] = transaction["rurTransfer"].get("valueDate")
            

            if transaction["rurTransfer"].get("cartInfo"):
                transaction["rur_cart_info_document_code"] = transaction["rurTransfer"]["cartInfo"].get("documentCode")
                transaction["rur_cart_info_document_date"] = transaction["rurTransfer"]["cartInfo"].get("documentDate")
                transaction["rur_cart_info_rest_amount"] = transaction["rurTransfer"]["cartInfo"].get("restAmount")
                transaction["rur_cart_info_document_number"] = transaction["rurTransfer"]["cartInfo"].get("documentNumber")
                transaction["rur_cart_info_document_content"] = transaction["rurTransfer"]["cartInfo"].get("documentContent")
                transaction["rur_cart_info_payment_number"] = transaction["rurTransfer"]["cartInfo"].get("paymentNumber")
            else:
                transaction["rur_cart_info_document_code"] = ''
                transaction["rur_cart_info_document_date"] = ''
                transaction["rur_cart_info_rest_amount"] = ''
                transaction["rur_cart_info_document_number"] = ''
                transaction["rur_cart_info_document_content"] = ''
                transaction["rur_cart_info_payment_number"] = ''

            if transaction["rurTransfer"].get("departmentalInfo"):

                transaction["rur_departmental_info_uip"] = transaction["rurTransfer"]["departmentalInfo"].get("uip")
                transaction["rur_departmental_drawer_status101"] = transaction["rurTransfer"]["departmentalInfo"].get("drawerStatus101")
                transaction["rur_departmental_kbk"] = transaction["rurTransfer"]["departmentalInfo"].get("kbk")
                transaction["rur_departmental_oktmo"] = transaction["rurTransfer"]["departmentalInfo"].get("oktmo")
                transaction["rur_departmental_reason_code106"] = transaction["rurTransfer"]["departmentalInfo"].get("reasonCode106")
                transaction["rur_departmental_tax_period107"] = transaction["rurTransfer"]["departmentalInfo"].get("taxPeriod107")
                transaction["rur_departmental_doc_number108"] = transaction["rurTransfer"]["departmentalInfo"].get("docNumber108")
                transaction["rur_departmental_doc_date109"] = transaction["rurTransfer"]["departmentalInfo"].get("docDate109")
                transaction["rur_departmental_payment_kind110"] = transaction["rurTransfer"]["departmentalInfo"].get("paymentKind110")
            
            else:
                transaction["rur_departmental_info_uip"] = ''
                transaction["rur_departmental_drawer_status101"] = ''
                transaction["rur_departmental_kbk"] = ''
                transaction["rur_departmental_oktmo"] = ''
                transaction["rur_departmental_reason_code106"] = ''
                transaction["rur_departmental_tax_period107"] = ''
                transaction["rur_departmental_doc_number108"] = ''
                transaction["rur_departmental_doc_date109"] = ''
                transaction["rur_departmental_payment_kind110"] = ''

    return page_data

def update_payments(connection, source_id:int, data_for_update:dict):

    payments_map = {
            "period_month": "period_month",
            "id": "uuid",
            "amount_amount": "amount_amount",
            "amount_currency_name": "amount_currency_name",
            "amount_rub_amount": "amount_rub_amount",
            "amount_rub_currency_name": "amount_rub_currency_name",
            "corresponding_account": "correspondingAccount",
            "direction": "direction",
            "document_date": "documentDate",
            "filial": "filial",
            "number": "number",
            "operation_code": "operationCode",
            "operation_date": "operationDate",
            "payment_purpose": "paymentPurpose",
            "priority": "priority",
            "transaction_id": "transactionId",
            "debtor_code": "debtorCode",
            "extended_debtor_code": "extendedDebtorCode",


            "rur_departmental_info_uip": "rur_departmental_info_uip",
            "rur_departmental_drawer_status101": "rur_departmental_drawer_status101",
            "rur_departmental_kbk": "rur_departmental_kbk",
            "rur_departmental_oktmo": "rur_departmental_oktmo",
            "rur_departmental_reason_code106": "rur_departmental_reason_code106",
            "rur_departmental_tax_period107": "rur_departmental_tax_period107",
            "rur_departmental_doc_number108": "rur_departmental_doc_number108",
            "rur_departmental_doc_date109": "rur_departmental_doc_date109",
            "rur_departmental_payment_kind110": "rur_departmental_payment_kind110",

            "rur_cart_info_document_code": "rur_cart_info_document_code",
            "rur_cart_info_document_date": "rur_cart_info_document_date",
            "rur_cart_info_rest_amount": "rur_cart_info_rest_amount",
            "rur_cart_info_document_number": "rur_cart_info_document_number",
            "rur_cart_info_document_content": "rur_cart_info_document_content",
            "rur_cart_info_payment_number": "rur_cart_info_payment_number",

            "rur_delivery_kind": "rur_delivery_kind",
            "rur_payee_account": "rur_payee_account",
            "rur_payee_bank_bic": "rur_payee_bank_bic",
            "rur_payee_bank_corr_account": "rur_payee_bank_corr_account",
            "rur_payee_bank_name": "rur_payee_bank_name",
            "rur_payee_inn": "rur_payee_inn",
            "rur_payee_kpp": "rur_payee_kpp",
            "rur_payee_name": "rur_payee_name",
            "rur_payer_account": "rur_payer_account",
            "rur_payer_bank_bic": "rur_payer_bank_bic",
            "rur_payer_bank_corr_account": "rur_payer_bank_corr_account",
            "rur_payer_bank_name": "rur_payer_bank_name",
            "rur_payer_inn": "rur_payer_inn",
            "rur_payer_kpp": "rur_payer_kpp",
            "rur_payer_name": "rur_payer_name",
            "rur_paying_condition": "rur_paying_condition",
            "rur_purpose_code": "rur_purpose_code",
            "rur_receipt_date": "rur_receipt_date",
            "rur_value_date": "rur_value_date"
        }
    
    load_data = data_for_update.get('transactions')
    if load_data is None:
        return ''
    
    load_data = get_payments_for_update(load_data)

    my_utility.update_dim_raw(connection, load_data, "payments", "banks_raw.alfa_payments", payments_map, source_id)

    cursor_list = data_for_update.get("_links")
    next_cursor = ''
    for link in cursor_list:
        if link['rel'] == 'next':
            next_cursor = link['href']
            break

    return next_cursor


def set_export_status(conn, source_id:int, datefrom: date, dateto: date):
    cursor = conn.cursor()
    
    cursor.execute("""insert into 
                            banks_raw.loaded_data_by_period (source_id, period_month, loaded_date)
                        select 
                            %(source_id)s source_id,
                            period_plan.period_month,
                            case 
                                when period_plan.period_month = date_trunc('month', (%(dateto)s - interval '1 day'))::Date then
                                    (%(dateto)s - interval '1 day')::Date
                                else
                                    operate.end_of_month(period_plan.period_month)
                            end	 as loaded_date
                    
                        from operate.get_date_period_table_fnc(date_trunc('month', %(datefrom)s)::Date, (%(dateto)s - interval '1 day')::Date) period_plan

                        on conflict (source_id, period_month) 
                        do update
                        SET loaded_date = EXCLUDED.loaded_date,
                            date_update = current_timestamp;""", {"source_id": source_id, "datefrom": datefrom, "dateto":dateto})

    conn.commit()
    cursor.close()

def get_token(conn, client_id, client_secret, refresh_token, certificate, private_key, passcode):
    #session = requests.Session()
    session = get_session(certificate, private_key, passcode)
    url = "https://baas.alfabank.ru/oidc/token"

    session.headers.update({
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json" 
    })

    payload = {'grant_type': 'refresh_token',
            'refresh_token': refresh_token,
            'client_id': client_id,
            'client_secret': client_secret}

    token = None

    #with session.post(url, data=payload, cert=(certificate, '4321', private_key)) as response:
    with session.post(url, data=payload) as response:
        result = json.loads(response.text)
        print(result)
        with conn.cursor() as cursor:
            cursor.execute("""update banks_raw.alfa_params
                              set
                                refresh_token = %(refresh_token)s 
                              where client_id = %(client_id)s
                           """, {'client_id': client_id, 'refresh_token': result['refresh_token']})
            token = result['access_token']
        conn.commit()
    return token

def export_account_data_from_alfa_to_rds(source_id:int, datefrom: date, dateto: date, plan_token = ''):
    with my_utility.get_db_connection() as conn:

        bucket_name = 'arbat-hotel-additional-data'
        prefix = 'test-alfa-cert/'

        cursor = conn.cursor()
        cursor.execute("""select 
                          so.source_external_key as account,
                          so.source_password as client_id,
                          ap.client_secret as client_secret,
                          ap.refresh_token as refresh_token,
                          ap.certificate as certificate,
                          ap.private_key as private_key,
                          ap.passcode as passcode
                        from operate.sources so join banks_raw.alfa_params ap 
                        on so.source_password = ap.client_id
                        where so.id = %(source_id)s
                        limit 1""", {'source_id': source_id})
    
        if cursor.rowcount < 1:
            return my_utility.get_response({'FormatError': source_id})

        cred_data = cursor.fetchone()
        account = cred_data[0]
        token = plan_token
        
        cert_key = prefix + cred_data[4]
        key_key = prefix + cred_data[5]
        passcode = cred_data[6]

        cert_content = "/tmp/" + cred_data[4]
        key_content = "/tmp/" + cred_data[5]

        response = my_utility.get_object_s3(bucket_name, cert_key)
        with open(cert_content, 'wb') as f:
            f.write(response['Body'].read())

        response = my_utility.get_object_s3(bucket_name, key_key)
        with open(key_content, 'wb') as f:
            f.write(response['Body'].read())

        if not plan_token:
            token = get_token(conn, cred_data[1], cred_data[2], cred_data[3], cert_content, key_content, passcode)
        

        current_date = datefrom
        while current_date < dateto:
            next_cursor = ''
            while True:
                #print(get_accounts(token))
                #print(token)
                #print(account)
                print(current_date)
                payments = get_payments(token, account, current_date, next_cursor, cert_content, key_content, passcode)
                #print(payments)
                next_cursor = update_payments(conn, source_id, payments)
                #payment_ids.extend(payments['operationId'])
                #print(payments)
                if next_cursor == '':
                    break

            current_date += timedelta(days=1)

        set_export_status(conn, source_id, datefrom, dateto)
        os.remove(cert_content)
        os.remove(key_content)


def lambda_handler(event, context):

    source_id = event['source_id']
    datefrom = datetime.strptime(event['datefrom'], '%d.%m.%Y')
    dateto = datetime.strptime(event['dateto'], '%d.%m.%Y')
    token = event['token']

    export_account_data_from_alfa_to_rds(source_id, datefrom, dateto, token)
