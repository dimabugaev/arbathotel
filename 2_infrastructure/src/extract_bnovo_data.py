import my_utility
import json

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
	        "ceo": "ceo"
        }

    for row in rows:
        http_session = my_utility.get_autorized_http_session_bnovo(row[0], row[1])
        #my_utility.update_dim_raw(conn, get_items(http_session)["items"], "items", "bnovo_raw.items", items_map, row[2])
        #my_utility.update_dim_raw(conn, [get_account_details(http_session)["hotel"]], "hotel", "bnovo_raw.hotels", hotels_map, row[2])
        my_utility.update_dim_raw(conn, get_suppliers(http_session)["suppliers"], "suppliers", "bnovo_raw.suppliers", suppliers_map, row[2])



    cursor.close()
    conn.close()   


def lambda_handler(event, context):
    export_data_from_bnovo_to_rds()