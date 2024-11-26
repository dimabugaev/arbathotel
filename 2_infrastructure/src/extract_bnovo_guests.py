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

    return my_utility.get_response_text_json(session, url)

def get_no_applyed_guests(session):
    items = {}
    url = "https://online.bnovo.ru/ufms/register/" 

    print(url)

    return my_utility.get_response_text_json(session, url)    

def get_guests_no_applyed_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["guests_ids"] = []

    if guests_data.get("bookings") is not None:
        for guest in guests_data["bookings"]:
            res["guests_ids"].append({"booking_id": guest["id"], "guest_id": guest["customer"]["id"]})

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

def get_booking_notes_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["booking_notes"] = []
    res["booking_notes_ids"] = []

    for booking_note in guests_data["booking_notes"]:
        res["booking_notes"].append(booking_note)
        res["booking_notes_ids"].append(booking_note["id"])

    return res

def get_cancel_reasons_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["cancel_reasons"] = []
    res["cancel_reasons_ids"] = []

    res["cancel_reasons"].append(guests_data["cancel_reason"])
    res["cancel_reasons_ids"].append(guests_data["cancel_reason"]["id"])

    return res

def get_users_data_for_update(guests_data: dict) -> dict:
    
    res = {}
    res["users"] = []
    res["users_ids"] = []

    res["users"].append(guests_data["created_user"])
    res["users_ids"].append(guests_data["created_user"]["id"])

    return res


def update_guests(connection, session, source_id: int, period: date):
    
    booking_notes_map = {            
	        "id": "id",
            "booking_id": "booking_id",
            "user_id": "user_id",
            "name": "name",
            "description": "description"
        }

    cancel_reasons_map = {            
	        "id": "id",
            "name": "name",
            "hotel_id": "hotel_id"
        }

    users_map = {            
	        "id": "id",
            "username": "username",
            "email": "email",
            "logins": "logins",
            "last_login": "last_login",
            "forget_hash": "forget_hash",
            "name": "name",
            "middlename": "middlename",
            "surname": "surname",
            "deleted": "deleted",
            "last_notifications_view_date": "last_notifications_view_date" 
        }
     

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
            b.source_id = %(source_id)s and b.arrival_date <= %(period)s and b.departure_date >= %(departure_from)s   
    """, {'source_id': source_id, 'period': period, 'departure_from': departure_from})

    rows = cursor.fetchall()
    guest_ids = []
    for row in rows:
        guest_data_raw = get_booking_guests(session, row[0])
        guest_data = get_guests_data_for_update(guest_data_raw)

        user_data = get_users_data_for_update(guest_data_raw["booking"])
        booking_notes_data = get_booking_notes_for_update(guest_data_raw["booking"])
        cancel_reasons_data = get_cancel_reasons_for_update(guest_data_raw["booking"])


        if len(user_data["users"]) > 0:
            insert_query = f"""
            INSERT INTO bnovo_raw.booking_users_link (source_id, booking_id, user_id) 
            VALUES {', '.join([f"('{source_id}', '{row[0]}', "+ str(user["id"]) +")" for user in user_data["users"]])}
            ON CONFLICT DO UPDATE SET user_id = EXCLUDED.user_id;
            """
            cursor.execute(insert_query)

            my_utility.update_dim_raw(connection, user_data["users"], "users"+uuid.uuid4().hex, "bnovo_raw.users", users_map, source_id)

        if len(cancel_reasons_data["cancel_reasons"]) > 0:
            insert_query = f"""
            INSERT INTO bnovo_raw.booking_cancel_reason_link (source_id, booking_id, cancel_reason_id) 
            VALUES {', '.join([f"('{source_id}', '{row[0]}', "+ str(cancel_reason["id"]) +")" for cancel_reason in cancel_reasons_data["cancel_reasons"]])}
            ON CONFLICT DO UPDATE SET cancel_reason_id = EXCLUDED.cancel_reason_id;
            """
            cursor.execute(insert_query)

            my_utility.update_dim_raw(connection, cancel_reasons_data["cancel_reasons"], "cancel_reasons"+uuid.uuid4().hex, "bnovo_raw.cancel_reasons", cancel_reasons_map, source_id)    

        if len(booking_notes_data["booking_notes"]) > 0:
            
            delete_query = "DELETE FROM bnovo_raw.booking_notes WHERE booking_id = %(booking_id)s and id NOT IN %(booking_notes_ids)s;"
            cursor.execute(delete_query, {'booking_id': row[0], 'booking_notes_ids': tuple(booking_notes_data["booking_notes_ids"])})

            my_utility.update_dim_raw(connection, booking_notes_data["booking_notes"], "booking_notes"+uuid.uuid4().hex, "bnovo_raw.booking_notes", booking_notes_map, source_id)    


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
                INSERT INTO bnovo_raw.temp_no_applyed_guests (source_id, booking_id, guest_id) 
                VALUES {', '.join([f"('{source_id}', "+ str(guest['booking_id']) +", "+ str(guest['guest_id']) +")" for guest in guest_no_applyed_data["guests_ids"]])}
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