import my_utility

def get_invoice_data(session, page: int = 1):

    url = "https://online.bnovo.ru/finance/invoices?payment_up_to=0&page={}".format(
        page    
    ) 

    print(url)

    return my_utility.get_response_text_json(session, url)

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
            #"period_month": "period_month",
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
    page_count = min(100, page_count)  #limit pages

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


    # if (len(invoices_ids) > 0):

    #     cursor = connection.cursor()
    #     cursor.execute("""
    #         DELETE FROM bnovo_raw.invoices
    #         WHERE 
    #             source_id = %(source_id)s  
    #             AND id not in %(invoices_ids)s;
    #     """, {'source_id': source_id, 
    #         'invoices_ids': tuple(invoices_ids)})
        
    #     connection.commit()
    #     cursor.close()


def export_bills_from_bnovo_to_rds(source_id: int, sid: str = ""):
    
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

        update_invoice(conn, http_session, source_id)

        cursor.close()
        return True


def lambda_handler(event, context):

    #sid = event['sid']
    sid = ''
    source_id = event['source_id']

    export_bills_from_bnovo_to_rds(source_id, sid)