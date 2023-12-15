import my_utility
import json
from datetime import date, datetime, timedelta
import pytz
import time
import uuid

def get_ufms_data(session, page: int = 1):

    #date_begin = my_utility.get_begin_month_by_date(period)
    #date_end = my_utility.get_end_month_by_date(period)


    items = {}
    url = "https://online.bnovo.ru/ufms/statuses?c=100&page={}".format(
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


def get_current_day_ufms_data(session, period: date, page: int = 1):

    yesterday = period - timedelta(days=1)

    items = {}

    url = "https://online.bnovo.ru/ufms/statuses?citizenship=all&dates_arrival={}+-+{}&dates_departure=&c=100&page={}".format(
        yesterday.strftime('%d.%m.%Y').replace('.', '%2F'),
        period.strftime('%d.%m.%Y').replace('.', '%2F'),
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


def get_ufms_data_pages_for_update(page_data: dict) -> dict:

    res = {}
    res["ufms"] = []

    if page_data.get("bookings") is not None:
        for application in page_data["bookings"]:
            res["ufms"].append(page_data["bookings"][application]["extra"]["ufms"])

    return res

def update_ufms(connection, session, source_id: int, period: date, current_day: bool = False):
    
    ufms_data_map = {
            
            "id": "id",
	        "hotel_id": "hotel_id",
            "booking_id": "booking_id",
            "customer_id": "customer_id",
            "status": "status",
            "scala_id": "scala_id",
            "scala_number": "scala_number",
            "last_error": "last_error",
            "last_attempt_date": "last_attempt_date",
            "create_date": "create_date",
            "update_date": "update_date",
            "scala_status": "scala_status",
            "citizenship_id": "citizenship_id",
            "arrival": "arrival",
            "departure": "departure",
            "customer_name": "customer_name",
            "customer_surname": "customer_surname"
        }
    
    if current_day:
        first_page_data = get_current_day_ufms_data(session, period)
    else:
        first_page_data = get_ufms_data(session)

    page_count = first_page_data['pages']['total_pages']


    data_page = get_ufms_data_pages_for_update(first_page_data)
    current_page = 1
    while True:

        my_utility.update_dim_raw(connection, data_page["ufms"], "ufms"+uuid.uuid4().hex, "bnovo_raw.ufms_data", ufms_data_map, source_id)

        current_page += 1
        if current_page > page_count:
            break    

        if current_day:
            next_page_data = get_current_day_ufms_data(session, period, current_page)
        else:
            next_page_data = get_ufms_data(session, current_page)

        data_page = get_ufms_data_pages_for_update(next_page_data)




def export_ufms_from_bnovo_to_rds(source_id: int, period: date, sid: str = "", current_day: bool = False):
    
    with my_utility.get_db_connection() as conn:
        cursor = conn.cursor()


        http_session = None

        if len(sid) == 0:
            session_cred = my_utility.get_binovo_cred(conn, source_id)
            if session_cred['username'] is None:
                print('Credentions is absent!!')
                return False
            http_session = my_utility.get_autorized_http_session_bnovo(session_cred['username'], session_cred['password'])
        else:
            http_session = my_utility.get_http_session_bnovo_by_sid(sid)

        

        update_ufms(conn, http_session, source_id, period, current_day)

        cursor.close()
        return True


def lambda_handler(event, context):

    sid = event['sid']
    source_id = event['source_id']

    current_day = False
    if event.get('all_data') is None:
        period = datetime.now(pytz.timezone('Europe/Moscow')).date()
        current_day = True
    else:
        #period = date(event['year'], event['month'], 1)
        period = None
    
    export_ufms_from_bnovo_to_rds(source_id, period, sid, current_day)