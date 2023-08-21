import my_utility
import json
import time

def get_items(session):

    items = {}
    url = "https://online.bnovo.ru/finance/items"

    with session.get(url) as response:
        items = json.loads(response.text) 

    return items

def get_account_details(session):

    account_details = {}

    url = "https://online.bnovo.ru/account/current"

    with session.get(url) as response:
        account_details = json.loads(response.text)
    
    return account_details

def get_suppliers(session):

    suppliers = {}

    url = "https://online.bnovo.ru/finance/details"

    with session.get(url) as response:
        suppliers = json.loads(response.text)
    
    return suppliers


def get_invoice_data(session, page: int = 1):


    items = {}
    url = "https://online.bnovo.ru/finance/invoices?payment_up_to=0&page={}".format(
        page    
    ) 

    print(url)

    count_of_rep = 3
    for i in range(count_of_rep):
        with session.get(url) as response:
            if response is None:
                if i == count_of_rep - 1:
                    raise ValueError('-- bad request ALL TIMES is NULL!!--')    
                print('-- bad request ... delay and repeat attempt # ' + (i+1))
                time.sleep(1)
                continue
            items = json.loads(response.text)
            break 

    return items

def get_invoice_data_pages_for_update(page_data: dict) -> dict:
    #date_begin = my_utility.get_begin_month_by_date(period)

    res = {}
    res["invoices"] = []
    res["invoices_id"] = []

    for invoice in page_data["invoices"]:
        #str_n = 0
        #invoice["period_month"] = date_begin
        res["invoices"].append(invoice)
        res["invoices_id"].append(invoice["id"])

    return res

def update_invoice(connection, session, source_id: int):
    
    invoices_map = {
            "period_month": "period_month",
            "id": "id",
            "number": "number",
            "hotel_id": "hotel_id",
            "booking_id": "booking_id",
            "booking_number": "booking_number",
            "supplier_id": "supplier_id",
            "supplier": "supplier",
            "customer_id": "customer_id",
            "customer": "customer",
            "hotel_supplier_id": "hotel_supplier_id",
            "hotel_supplier": "hotel_supplier",
            "type_id": "type_id",
            "supplier_type_id": "supplier_type_id",
            "amount": "amount",
            "deadline_date": "deadline_date",
            "message": "message",
            "vat": "vat",
            "create_date": "create_date",
            "payer_name": "payer_name",
            "amount_nds": "amount_nds",
            "online_number": "online_number",
            "online_hash": "online_hash",
            "online_link": "online_link",
            "payed_amount": "payed_amount",
            "unread": "unread",
            "paid_from_system": "paid_from_system",
            "message_for_invoices": "message_for_invoices",
            "payment_system_name": "payment_system_name",
            "group_id": "group_id",
            "tax_system_id": "tax_system_id",
            "denied_from_system": "denied_from_system",
            "denied_payment_system_name": "denied_payment_system_name",
            "deactivated": "deactivated",
            "refunded": "refunded",
            "delivery_acts": "delivery_acts"
        }
    
    first_page_data = get_invoice_data(session)

    page_count = first_page_data['pages']['total_pages']

    invoices_ids = []

    data_page = get_invoice_data_pages_for_update(first_page_data)
    current_page = 1
    while True:

        my_utility.update_dim_raw(connection, data_page["invoices"], "invoices", "bnovo_raw.invoices", invoices_map, source_id)

        invoices_ids.extend(data_page["invoices_id"])

        current_page += 1
        if current_page > page_count:
            break    

        data_page = get_invoice_data_pages_for_update(get_invoice_data(session, current_page))


    if (len(invoices_ids) > 0):

        cursor = connection.cursor()
        cursor.execute("""
            DELETE FROM bnovo_raw.invoices
            WHERE 
                source_id = %(source_id)s  
                AND id not in %(invoices_ids)s;
        """, {'source_id': source_id, 
            'invoices_ids': tuple(invoices_ids)})
        
        connection.commit()
        cursor.close()


def export_data_from_bnovo_to_rds():
    conn = my_utility.get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""SELECT 
                        so.source_username, 
                        so.source_password,
                        so.id 
                      FROM operate.sources so
                      WHERE 
                        so.source_type = 2
                        AND coalesce(so.source_username, '') <> ''
                        AND coalesce(so.source_password, '') <> '' """)
    
    rows = cursor.fetchall()

    items_map = {
            "id": "id",
            "type_id": "type_id",
            "name": "name",
            "read_only": "read_only",
            "create_date": "create_date"
        }
    
    hotels_map = {
            "id": "id",
	        "name": "name",
	        "country": "country",
	        "city": "city",
	        "address": "address",
	        "postcode": "postcode",
	        "phone": "phone",
	        "email": "email",
	        "create_date": "create_date"
        }
    
    suppliers_map = {
            "id": "id",
	        "hotel_id": "hotel_id",
	        "name": "name",
	        "law_name": "law_name",
	        "email": "email",
	        "phone": "phone",
	        "site": "site",
	        "city": "city",
	        "address": "address",
	        "law_address": "law_address",
	        "inn": "inn",
	        "kpp": "kpp",
	        "account": "account",
	        "correspondent_account": "correspondent_account",
	        "bik": "bik",
	        "bank": "bank",
	        "ogrn": "ogrn",
	        "ceo": "ceo",
            "finance_supplier_id": "finance_supplier_id"
        }

    sid_map = {}
    for row in rows:
        http_session = my_utility.get_autorized_http_session_bnovo(row[0], row[1])
        print(http_session.cookies.get_dict())
        
        #print(http_session.cookies)

        my_utility.update_dim_raw(conn, get_items(http_session)["items"], "items", "bnovo_raw.items", items_map, row[2])
        my_utility.update_dim_raw(conn, [get_account_details(http_session)["hotel"]], "hotel", "bnovo_raw.hotels", hotels_map, row[2])
        my_utility.update_dim_raw(conn, get_suppliers(http_session)["suppliers"], "suppliers", "bnovo_raw.suppliers", suppliers_map, row[2])
        update_invoice(conn, http_session, row[2])

        sid_map[row[2]] = http_session.cookies.get('SID')


    cursor.close()
    conn.close()   

    return sid_map


def lambda_handler(event, context):
    sid_map = export_data_from_bnovo_to_rds()
    return sid_map