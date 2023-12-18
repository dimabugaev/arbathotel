import my_utility
import json
from datetime import date, datetime, timedelta
import pytz
import time
import uuid

def get_booking_guests(session, booking_id: str):

    items = {}
    url = "https://online.bnovo.ru/booking/guests/{}/".format(booking_id) 

    print(url)

    count_of_rep = 10
    for i in range(count_of_rep):
        with session.get(url) as response:
            if response is None:
                if i == count_of_rep - 1:
                    raise ValueError('-- bad request ALL TIMES is NULL!!--')    
                print('-- bad request ... delay and repeat attempt # ' + str(i+1))
                time.sleep(1)
                continue
            if response.text[0] == '<':
                if i == count_of_rep - 1:
                    raise ValueError('-- Too Many Requests ALL TIMES is Too many!!--')
                print('-- Too Many Requests ... delay and repeat attempt # ' + str(i+1))
                time.sleep(3)
                continue  
            items = json.loads(response.text)
            break 

    return items

def get_no_applyed_guests(session):
    items = {}
    url = "https://online.bnovo.ru/ufms/register/" 

    print(url)

    count_of_rep = 10
    for i in range(count_of_rep):
        with session.get(url) as response:
            if response is None:
                if i == count_of_rep - 1:
                    raise ValueError('-- bad request ALL TIMES is NULL!!--')    
                print('-- bad request ... delay and repeat attempt # ' + (i+1))
                time.sleep(1)
                continue 
            if response.text[0] == '<':
                if i == count_of_rep - 1:
                    raise ValueError('-- Too Many Requests ALL TIMES is Too many!!--')
                print('-- Too Many Requests ... delay and repeat attempt # ' + str(i+1))
                time.sleep(3)
                continue  
            items = json.loads(response.text)
            break 

    return items    

def get_guests_no_applyed_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["guests_ids"] = []

    if guests_data.get("bookings") is not None:
        for guest in guests_data["bookings"]:
            res["guests_ids"].append(guest["customer"]["id"])

    return res

def get_guests_data_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["guests"] = []
    res["guests_ids"] = []

    for guest in guests_data["customers"]:
        #str_n = 0
        for extra_key in guest["extra"]:
            guest[extra_key] = guest["extra"].get(extra_key)

        res["guests"].append(guest)
        res["guests_ids"].append(guest["id"])

    return res


def update_guests(connection, session, source_id: int, period: date):
    
    guests_map = {            
	        "id": "id",
            "hotel_id": "hotel_id",
            "country_id": "country_id",
            "country_name": "country_name",
            "citizenship_id": "citizenship_id",
            "citizenship_name": "citizenship_name",
            "name": "name",
            "surname": "surname",
            "email": "email",
            "phone": "phone",
            "birthdate": "birthdate",
            "postcode": "postcode",
            "city": "city",
            "address": "address",
            "passport_num": "passport_num",
            "passport_date_start": "passport_date_start",
            "passport_date_end": "passport_date_end",
            "notes": "notes",
            "tags": "tags",
            "guest_type": "guest_type",
            "gender": "gender",
            "middlename": "middlename",
            "birth_country_name": "birth_country_name",
            "birth_country_id": "birth_country_id",
            "birth_region_name": "birth_region_name",
            "birth_area_name": "birth_area_name",
            "birth_city_name": "birth_city_name",
            "birth_locality_name": "birth_locality_name",
            "document_type": "document_type",
            "document_series": "document_series",
            "document_number": "document_number",
            "document_unit_code": "document_unit_code",
            "document_organization_issued": "document_organization_issued",
            "document_date_issued": "document_date_issued",
            "document_date_end": "document_date_end",
            "address_free": "address_free",
            "address_fias": "address_fias",
            "address_region": "address_region",
            "address_region_only": "address_region_only",
            "address_area_only": "address_area_only",
            "address_street_name": "address_street_name",
            "address_house": "address_house",
            "address_housing": "address_housing",
            "address_flat": "address_flat",
            "address_date": "address_date",
            "migcard_series": "migcard_series",
            "migcard_number": "migcard_number",
            "migcard_date_arrival": "migcard_date_arrival",
            "migcard_kpp": "migcard_kpp",
            "migcard_kpp_code": "migcard_kpp_code",
            "migcard_date_start": "migcard_date_start",
            "migcard_date_end": "migcard_date_end",
            "representative_customer_id": "representative_customer_id",
            "relationtype_id": "relationtype_id",
            "representative_customer_full_name": "representative_customer_full_name"
        }
    
    departure_from = period - timedelta(days=1)

    cursor = connection.cursor()
    cursor.execute("""
        select 
            b.id 
        from 
            bnovo_raw.bookings b
        where 
            b.source_id = %(source_id)s and b.arrival::date <= %(period)s and b.departure::date >= %(departure_from)s   
    """, {'source_id': source_id, 'period': period, 'departure_from': departure_from})

    rows = cursor.fetchall()
    guest_ids = []
    for row in rows:
        guest_data = get_booking_guests(session, row[0])
        guest_data = get_guests_data_for_update(guest_data)

        if len(guest_data["guests"]) < 1:
            #connection.commit()
            continue

        insert_query = f"""
            INSERT INTO bnovo_raw.booking_guests_link (source_id, booking_id, guest_id) 
            VALUES {', '.join([f"('{source_id}', '{row[0]}', "+ str(guest["id"]) +")" for guest in guest_data["guests"]])}
            ON CONFLICT DO NOTHING;
            """
        cursor.execute(insert_query)

        delete_query = "DELETE FROM bnovo_raw.booking_guests_link WHERE booking_id = %(booking_id)s and guest_id NOT IN %(guests_ids)s;"
        cursor.execute(delete_query, {'booking_id': row[0], 'guests_ids': tuple(guest_data["guests_ids"])})

        
        my_utility.update_dim_raw(connection, guest_data["guests"], "guests"+uuid.uuid4().hex, "bnovo_raw.guests", guests_map, source_id)

    guest_no_applyed_data = get_no_applyed_guests(session)
    guest_no_applyed_data = get_guests_no_applyed_for_update(guest_no_applyed_data)

    delete_query = "DELETE FROM bnovo_raw.temp_no_applyed_guests WHERE source_id = %(source_id)s;"
    cursor.execute(delete_query, {'source_id': source_id})

    if len(guest_no_applyed_data["guests_ids"]) > 0:
        insert_query = f"""
                INSERT INTO bnovo_raw.temp_no_applyed_guests (source_id, guest_id) 
                VALUES {', '.join([f"('{source_id}', "+ str(guest) +")" for guest in guest_no_applyed_data["guests_ids"]])}
                ON CONFLICT DO NOTHING;
                """
        cursor.execute(insert_query)

    cursor.close()

    

    
    
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


def export_guests_from_bnovo_to_rds(source_id: int, sid: str = ""):
    
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

        update_guests(conn, http_session, source_id, period)

        cursor.close()
        return True


def lambda_handler(event, context):

    sid = event['sid']
    source_id = event['source_id']
    
    export_guests_from_bnovo_to_rds(source_id, sid)