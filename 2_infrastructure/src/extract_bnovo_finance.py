import my_utility
import json
from datetime import date

def get_finance_data(session, period: date, supplier_id: str, page: int = 1):

    date_begin = my_utility.get_begin_month_by_date(period)
    date_end = my_utility.get_end_month_by_date(period)


    items = {}
    url = "https://online.bnovo.ru/finance?finance_supplier_id={}&dfrom={}&dto={}&tto=23%3A59&page={}".format(
        supplier_id,
        date_begin.strftime('%d-%m-%Y'),
        date_end.strftime('%d-%m-%Y'),
        page    
    ) 

    print(url)
    with session.get(url) as response:
        items = json.loads(response.text) 

    return items

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

def update_balance(connection, source_id: int, period: date, supplier_id: str, first_page_data: dict):
    cursor = connection.cursor()

    cursor.execute("""
        DELETE FROM bnovo_raw.balance_by_period
        WHERE source_id = %(source_id)s AND period_month = %(period)s AND finance_supplier_id = %(supplier_id)s;

        INSERT INTO bnovo_raw.balance_by_period (source_id, period_month, finance_supplier_id, debet, credit)
        VALUES (%(source_id)s, %(period)s, %(supplier_id)s, %(debet)s, %(credit)s);
    """, {'source_id': source_id, 'period': my_utility.get_begin_month_by_date(period), 
            'supplier_id': supplier_id, 'debet': float(first_page_data['debet']), 'credit': float(first_page_data['credit'])})
    
    cursor.execute("""
        DELETE FROM bnovo_raw.total_balance
        WHERE source_id = %(source_id)s AND finance_supplier_id = %(supplier_id)s;

        INSERT INTO bnovo_raw.total_balance (source_id, finance_supplier_id, last_payment_balance)
        VALUES (%(source_id)s, %(supplier_id)s, %(last_payment_balance)s);
    """, {'source_id': source_id, 
            'supplier_id': supplier_id, 'last_payment_balance': float(first_page_data['last_payment']['balance'])})
    
    connection.commit()
    cursor.close()

def get_data_pages_for_update(page_data: dict, period: date) -> dict:
    date_begin = my_utility.get_begin_month_by_date(period)

    res = {}
    res["payments"] = []
    res["payment_records"] = []
    res["payments_id"] = []
    res["payments_records_id"] = []

    for payment in page_data["payments"]:
        str_n = 0
        for payment_record in payment["extra"]["payment_records"]:
            str_n += 1
            payment_record["id"] = payment["id"] + str(str_n)
            payment_record["payment_id"] = payment["id"]
            payment_record["period_month"] = date_begin
            res["payment_records"].append(payment_record)
            res["payments_records_id"].append(payment_record["id"]) 

        payment["period_month"] = date_begin
        res["payments"].append(payment)
        res["payments_id"].append(payment["id"])

    return res


def update_finance(connection, session, source_id: int, period: date, supplier_id: str, first_page_data: dict):
    page_count = first_page_data['pages']['total_pages']

    payments_map = {
            "period_month": "period_month",
            "id": "id",
            "supplier_id": "supplier_id",
            "contractor_id": "contractor_id",
            "external_hotel_id": "external_hotel_id",
            "external_booking_id": "external_booking_id",
            "external_user_id": "external_user_id",
            "external_user_name": "external_user_name",
            "external_payment_id": "external_payment_id",
            "external_supplier_id": "external_supplier_id",
            "passport": "passport",
            "name": "name",
            "type_id": "type_id",
            "item_id": "item_id",
            "amount": "amount",
            "balance": "balance",
            "paid_date": "paid_date",
            "reason": "reason",
            "create_date": "create_date",
            "fiscal_status": "fiscal_status",
            "sub_amount": "sub_amount",
            "id_command": "id_command"
        }
    
    payment_records_map = {
            "period_month": "period_month",
            "id": "id",
            "payment_id": "payment_id",
            "booking_id": "booking_id",
            "booking_number": "booking_number",
            "item_id": "item_id",
            "method_id": "method_id",
            "subject_id": "subject_id",
            "service_id": "service_id",
            "service_name": "service_name",
            "origin_country": "origin_country",
            "customs_doc_number": "customs_doc_number",
            "excise_sum": "excise_sum",
            "amount": "amount",
            "sub_amount": "sub_amount",
            "nds_value": "nds_value",
            "tax_system": "tax_system",
            "is_for_booking": "is_for_booking",
            "hotel_supplier_id": "hotel_supplier_id",
            "supplier_id": "supplier_id",
            "type_id": "type_id",
            "name": "name",
            "reason": "reason",
            "paid_date": "paid_date",
            "transferred_refund_id": "transferred_refund_id",
            "transferred_to_booking_number": "transferred_to_booking_number",
            "passport": "passport",
            "finance_goal": "finance_goal"
        }
    

    payment_ids = []
    payment_record_ids = []

    data_page = get_data_pages_for_update(first_page_data, period)
    current_page = 1
    while True:

        my_utility.update_dim_raw(connection, data_page["payments"], "payments", "bnovo_raw.payments", payments_map, source_id)
        my_utility.update_dim_raw(connection, data_page["payment_records"], "payment_records", "bnovo_raw.payment_records", payment_records_map, source_id)

        payment_ids.extend(data_page["payments_id"])
        payment_record_ids.extend(data_page["payments_records_id"])

        current_page += 1
        if current_page > page_count:
            break    

        data_page = get_data_pages_for_update(get_finance_data(session, period, supplier_id, current_page), period)

    cursor = connection.cursor()
    cursor.execute("""
        DELETE FROM bnovo_raw.payments
        WHERE 
            source_id = %(source_id)s 
            AND period_month = %(period)s 
            AND supplier_id = %(supplier_id)s
            AND id not in %(payments_ids)s;

        DELETE FROM bnovo_raw.payment_records
        WHERE 
            source_id = %(source_id)s 
            AND period_month = %(period)s 
            AND supplier_id = %(supplier_id)s
            AND id not in %(payment_records_ids)s;
    """, {'source_id': source_id, 'period': period,'supplier_id': supplier_id, 
          'payments_ids': tuple(payment_ids), 'payment_records_ids': tuple(payment_record_ids)})
    
    connection.commit()
    cursor.close()

   

def export_finance_from_bnovo_to_rds(source_id: int, period: date, sid: str = ""):
    
    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()

        cursor.execute("""
            SELECT
                finance_supplier_id
            FROM
                bnovo_raw.suppliers
            WHERE
                source_id = %(source_id)s    
        """, {'source_id': source_id})

        supp_ids = cursor.fetchall()

        http_session = None

        if len(sid) == 0:
            session_cred = get_binovo_cred(conn, source_id)
            if session_cred['username'] is None:
                return
            http_session = my_utility.get_autorized_http_session_bnovo(session_cred['username'], session_cred['password'])
        else:
            http_session = my_utility.get_http_session_bnovo_by_sid(sid)

        for supp_id in supp_ids:
            
            first_page_data = get_finance_data(http_session, period, supp_id[0])
            update_balance(conn, source_id, period, supp_id[0], first_page_data)
            update_finance(conn, http_session, source_id, period, supp_id[0], first_page_data)
            #print(first_page_data['last_payment'])

        cursor.close()
    

def lambda_handler(event, context):

    sid = event['sid']
    source_id = event['source_id']
    period = date(event['year'], event['month'], 1)




#https://online.bnovo.ru/finance?finance_supplier_id=2078&dfrom=10-04-2016&tfrom=00%3A00&dto=18-04-2023&tto=00%3A00&page=2
 #https://online.bnovo.ru/finance/items?finance_supplier_id=18141&dfrom=01-04-2023&dto=30-04-2023&tto=23%3A59&page=1