import my_utility
import json
from datetime import date, datetime, timedelta
import pytz
import time
import uuid
import sys

def get_booking_data(session, period: date, page: int = 1):

    date_begin = my_utility.get_begin_month_by_date(period)
    date_end = my_utility.get_end_month_by_date(period)


    items = {}
    url = "https://online.bnovo.ru/dashboard?create_from={}&create_to={}&advanced_search=2&c=100&page={}".format(
        date_begin.strftime('%d.%m.%Y'),
        date_end.strftime('%d.%m.%Y'),
        page    
    ) 

    print(url)

    return my_utility.get_response_text_json(session, url)


def get_current_day_booking_data(session, period: date, page: int = 1):

    departure_from = period - timedelta(days=1)

    items = {}
    url = "https://online.bnovo.ru/dashboard?arrival_to={}&departure_from={}&advanced_search=2&c=100&page={}".format(
        period.strftime('%d.%m.%Y'),
        departure_from.strftime('%d.%m.%Y'),
        page    
    ) 

    print(url)

    return my_utility.get_response_text_json(session, url)

def get_invoice_data(session, period: date, page: int = 1):

    date_begin = my_utility.get_begin_month_by_date(period)
    date_end = my_utility.get_end_month_by_date(period)


    items = {}
    url = "https://online.bnovo.ru/finance/invoices?date_from={}&date_to={}&page={}".format(
        date_begin.strftime('%d-%m-%Y'),
        date_end.strftime('%d-%m-%Y'),
        page    
    ) 

    print(url)

    return my_utility.get_response_text_json(session, url)

def get_booking_data_pages_for_update(page_data: dict, period: date) -> dict:
    date_begin = my_utility.get_begin_month_by_date(period)

    res = {}
    res["bookings"] = []
    res["bookings_id"] = []
    res["bookings_id_for_guest_request"] = []

    if page_data.get("bookings") is not None:
        for booking in page_data["bookings"]:
            #str_n = 0
            booking["period_month"] = date_begin
            booking["hotel_id"] = booking["hotel"]["id"]
            booking["adults"] = booking["extra"].get("adults")
            booking["children"] = booking["extra"].get("children")
            res["bookings"].append(booking)
            res["bookings_id"].append(booking["id"])
            #res["bookings_id_for_guest_request"].append(booking["id"])

    return res

def get_invoice_data_pages_for_update(page_data: dict, period: date) -> dict:
    date_begin = my_utility.get_begin_month_by_date(period)

    res = {}
    res["invoices"] = []
    res["invoices_id"] = []

    for invoice in page_data["invoices"]:
        #str_n = 0
        invoice["period_month"] = date_begin
        res["invoices"].append(invoice)
        res["invoices_id"].append(invoice["id"])

    return res

def update_booking(connection, session, source_id: int, period: date, current_day: bool = False):
    
    bookings_map = {
            "period_month": "period_month",
            "id": "id",
	
            "hotel_id": "hotel_id",
            "origin_source_id": "source_id",
            "provider_id": "provider_id",
            "source_name": "source_name",
            "source_icon": "source_icon",
            "status_id": "status_id",
            "status_name": "status_name",
            "status_color": "status_color",
            "customer_id": "customer_id",
            "agency_id": "agency_id",
            "supplier_id": "supplier_id",
            "supplier_name": "supplier_name",
            "agency_name": "agency_name",
            "agency_commission": "agency_commission",
            "agency_not_pay_services_commission": "agency_not_pay_services_commission",
            "source_commission": "source_commission",
            "ancillary_commission": "ancillary_commission",
            "number": "number",
            "create_date": "create_date",
            "arrival": "arrival",
            "departure": "departure",
            "real_arrival": "real_arrival",
            "real_departure": "real_departure",
            "original_arrival": "original_arrival",
            "original_departure": "original_departure",
            "amount": "amount",
            "amount_provider": "amount_provider",
            "is_blocked": "is_blocked",
            "name": "name",
            "surname": "surname",
            "phone": "phone",
            "notes": "notes",
            "link_id": "link_id",
            "external_res_id": "external_res_id",
            "provider_booking_id": "provider_booking_id",
            "extra_provider": "extra_provider",
            "cancel_date": "cancel_date",
            "discount_type": "discount_type",
            "discount_amount": "discount_amount",
            "discount_reason_id": "discount_reason_id",
            "discount_reason": "discount_reason",
            "guarantee": "guarantee",
            "is_guarantee_encrypted": "is_guarantee_encrypted",
            "prices_services_total": "prices_services_total",
            "prices_rooms_total": "prices_rooms_total",
            "payments_total": "payments_total",
            "provided_total": "provided_total",
            "customers_total": "customers_total",
            "plan_name": "plan_name",
            "initial_room_type_name": "initial_room_type_name",
            "current_room": "current_room",
            "current_room_clean_status": "current_room_clean_status",
            "room_name": "room_name",
            "has_linked_bookings": "has_linked_bookings",
            "has_linked_cancelled_bookings": "has_linked_cancelled_bookings",
            "early_check_in": "early_check_in",
            "late_check_out": "late_check_out",
            "unread": "unread",
            "uu": "uu",
            "created_user": "created_user",
            "created_user_id": "created_user_id",
            "created_user_name": "created_user_name",
            "created_user_surname": "created_user_surname",
            "group_id": "group_id",
            "group_code": "group_code",
            "group_name": "group_name",
            "group_create_date": "group_create_date",
            "actual_price": "actual_price",
            "email": "email",
            "customer_notes": "customer_notes",
            "ota_info": "ota_info",
            "cancel_reason": "cancel_reason",
            "discount_reason_relation": "discount_reason_relation",
            "board_nutritia": "board_nutritia",
            "online_warranty_deadline_date": "online_warranty_deadline_date",
            "auto_booking_cancel": "auto_booking_cancel",
            "adults": "adults",
            "children": "children"
        }
    
    if current_day:
        first_page_data = get_current_day_booking_data(session, period)
    else:
        first_page_data = get_booking_data(session, period)

    page_count = first_page_data['pages']['total_pages']

    booking_ids = []
    booking_ids_for_guest_request = []

    data_page = get_booking_data_pages_for_update(first_page_data, period)
    current_page = 1
    while True:

        my_utility.update_dim_raw(connection, data_page["bookings"], "bookings"+uuid.uuid4().hex, "bnovo_raw.bookings", bookings_map, source_id)

        booking_ids.extend(data_page["bookings_id"])
        booking_ids_for_guest_request.extend(data_page["bookings_id_for_guest_request"])

        current_page += 1
        if current_page > page_count:
            break    

        if current_day:
            next_page_data = get_current_day_booking_data(session, period, current_page)
        else:
            next_page_data = get_booking_data(session, period, current_page)

        data_page = get_booking_data_pages_for_update(next_page_data, period)


    #delete invoices probably loading in last times but not existing now
    if (len(booking_ids) > 0 and not current_day):

        cursor = connection.cursor()
        cursor.execute("""
            DELETE FROM bnovo_raw.bookings
            WHERE 
                source_id = %(source_id)s 
                AND period_month = %(period)s 
                AND id not in %(booking_ids)s;
        """, {'source_id': source_id, 'period': period, 
            'booking_ids': tuple(booking_ids)})
        
        connection.commit()
        cursor.close()
        
    if (datetime.now().year != period.year or datetime.now().month != period.month) and not current_day:
        
        cursor = connection.cursor()
        cursor.execute("""
            INSERT INTO bnovo_raw.load_bookings_by_period (source_id, period_month)
            VALUES (%(source_id)s, %(period)s);
        """, {'source_id': source_id, 'period': my_utility.get_begin_month_by_date(period)})


        connection.commit()
        cursor.close()


    # if (len(booking_ids_for_guest_request) > 0):

    #     cursor = connection.cursor()

    #     insert_query = f"""
    #         INSERT INTO bnovo_raw.bookings_for_guests_request (source_id, booking_id) 
    #         VALUES {', '.join([f"('{source_id}', "+ str(booking_id) +")" for booking_id in booking_ids_for_guest_request])}
    #         ON CONFLICT DO NOTHING;
    #         """
    #     cursor.execute(insert_query)
        
    #     connection.commit()
    #     cursor.close()

def update_invoice(connection, session, source_id: int, period: date):
    
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
    
    first_page_data = get_invoice_data(session, period)

    page_count = first_page_data['pages']['total_pages']

    invoices_ids = []

    data_page = get_invoice_data_pages_for_update(first_page_data, period)
    current_page = 1
    while True:

        my_utility.update_dim_raw(connection, data_page["invoices"], "invoices"+uuid.uuid4().hex, "bnovo_raw.invoices", invoices_map, source_id)

        invoices_ids.extend(data_page["invoices_id"])

        current_page += 1
        if current_page > page_count:
            break    

        data_page = get_invoice_data_pages_for_update(get_invoice_data(session, period, current_page), period)


    if (len(invoices_ids) > 0):

        cursor = connection.cursor()
        cursor.execute("""
            DELETE FROM bnovo_raw.invoices
            WHERE 
                source_id = %(source_id)s 
                AND period_month = %(period)s 
                AND id not in %(invoices_ids)s;
        """, {'source_id': source_id, 'period': period, 
            'invoices_ids': tuple(invoices_ids)})
        
        connection.commit()
        cursor.close()

def export_booking_from_bnovo_to_rds(source_id: int, period: date, sid: str = "", current_day: bool = False):
    
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

        

        update_booking(conn, http_session, source_id, period, current_day)

        #It's removed to the function for extract data because of bnovo doesn't support getting data of invoices's by period
        #update_invoice(conn, http_session, source_id, period)
        #print(first_page_data['last_payment'])

        cursor.close()
        return True


def lambda_handler(event, context):

    sid = event['sid']
    source_id = event['source_id']

    current_day = False
    if event.get('month') is None:
        period = datetime.now(pytz.timezone('Europe/Moscow')).date()
        current_day = True
    else:
        period = date(event['year'], event['month'], 1)
    
    export_booking_from_bnovo_to_rds(source_id, period, sid, current_day)
    #export_bills_from_bnovo_to_rds(source_id, period, sid)