import my_utility
import json
from datetime import date, datetime, timedelta
import pytz
import time
import uuid

def my_query(session):

    items = {}
    url = "https://online.bnovo.ru/booking/guests/51317896/" 

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
            print('-----')
            print(response.text[0])
            print('-----')
            try:
                items = json.loads(response.text)
            except:
                print(response.text[0])
                raise Exception("err hapend")
            print(items)
            break 

    return items




def launch_query(connection, session, source_id: int, period: date):
    
    
    result = my_query(session)
    
    
    
    # while True:

    #     my_utility.update_dim_raw(connection, data_page["bookings"], "bookings"+uuid.uuid4().hex, "bnovo_raw.bookings", bookings_map, source_id)

    #     booking_ids.extend(data_page["bookings_id"])
    #     booking_ids_for_guest_request.extend(data_page["bookings_id_for_guest_request"])

    #     current_page += 1
    #     if current_page > page_count:
    #         break    

    #     data_page = get_booking_data_pages_for_update(get_booking_data(session, period, current_page), period)


    # #delete invoices probably loading in last times but not existing now
    # if (len(booking_ids) > 0):

    #     cursor = connection.cursor()
    #     cursor.execute("""
    #         DELETE FROM bnovo_raw.bookings
    #         WHERE 
    #             source_id = %(source_id)s 
    #             AND period_month = %(period)s 
    #             AND id not in %(booking_ids)s;
    #     """, {'source_id': source_id, 'period': period, 
    #         'booking_ids': tuple(booking_ids)})
        
    #     connection.commit()
    #     cursor.close()


def test_bnovo_query(source_id: int, sid: str = ""):
    
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

        period = datetime.now(pytz.timezone('Europe/Moscow')).date()

        launch_query(conn, http_session, source_id, period)

        cursor.close()
        return True


def lambda_handler(event, context):

    sid = event['sid']
    source_id = event['source_id']
    
    test_bnovo_query(source_id, sid)