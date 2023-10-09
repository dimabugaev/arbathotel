import my_utility
import json
import time
import psycopg2.extras as pe

def create_payments_bnovo_after_transformation():
    conn = my_utility.get_db_connection()

    bnovo_work_sessions = {}

    cursor = conn.cursor(cursor_factory=pe.NamedTupleCursor)
    

    cursor.execute("""select
                        task_key,    
                        source_id,
                        booking_id,
                        booking_number,
                        action,
                        reason,
                        is_for_booking,
                        hotel_supplier_id,
                        supplier_id,
                        type_id,
                        create_booking_payment,
                        amount,
                        temp_payment_id,
                        paid_date,
                        paid_date_hour,
                        paid_date_minute
                    from
                        calc_to_make_bank_payment_bnovo""")
    
    rows = cursor.fetchall()

    url = "https://online.bnovo.ru/booking/create_payment"

    for row in rows:
        current_source = row.source_id
        
        current_source = 23 #TEST Учебный отель
        test_booking_id = 43054985
        test_booking_number = 'A7XJW-020523'

        http_session = bnovo_work_sessions.get(current_source)
        if http_session is None:
            http_session = my_utility.get_bnovo_session_by_source_id(conn, current_source)
            bnovo_work_sessions[current_source] = http_session
            http_session.headers.update({
                "Content-Type": "application/json",
                "Accept": "application/json",
                "X-Requested-With": "XMLHttpRequest" 
            })



        post_data = {}
        post_data['booking_id'] = str(test_booking_id)
        post_data['group_id'] = '0'
        post_data['payment_id'] = '0'
        post_data['finance_payment_id'] = '0'
        post_data['action'] = row.action
        post_data['is_finance'] = '0'
        post_data['is_finance_refund'] = '0'
        post_data['fiscal_check_printed'] = '0'
        post_data['transferred_refund_id'] = '0'
        post_data['transfer_refund_sum'] = '0'
        post_data['transferred_to_booking_number'] = ''
        post_data['reason'] = ''
        post_data['is_for_booking'] = '1'
        post_data['is_supplier'] = '0'
        post_data['hotel_supplier_id'] = '9273'
        #post_data['supplier_id'] = row.supplier_id
        post_data['supplier_id'] = '0'
        post_data['name'] = 'петров иван'
        post_data['passport'] = ''
        post_data['type_id'] = str(row.type_id)
        post_data['services'] = {}
        post_data['services']['booking_id'] = [str(test_booking_id)]
        post_data['services']['booking_number'] = [test_booking_number]
        post_data['services']['create_booking_payment'] = [str(row.create_booking_payment)]
        post_data['services']['invoice_id'] = ['0']
        post_data['services']['item_id'] = ['1']
        post_data['services']['method_id'] = ['4']
        post_data['services']['subject_id'] = ['4']
        post_data['services']['service_id'] = ['0']
        post_data['services']['service_name'] = [row.reason]
        post_data['services']['origin_country'] = ['0']
        post_data['services']['customs_doc_number'] = ['']
        post_data['services']['excise_sum'] = ['']
        post_data['services']['amount'] = [str(row.amount)]
        post_data['services']['sub_amount'] = ['0']
        post_data['services']['nds_value'] = ['']
        post_data['services']['tax_system'] = ['']
        post_data['services']['temp_payment_id'] = [str(row.temp_payment_id)]
        
        post_data['paid_date'] = row.paid_date
        post_data['paid_date_hour'] = row.paid_date_hour
        post_data['paid_date_minute'] = row.paid_date_minute

        print(post_data)
        res = {}
        with http_session.post(url, json=post_data) as response:
            res = json.loads(response.text)

            if isinstance(res, dict) and res.get('result') == 'success':
                cursor.execute("""
                                    DELETE FROM calc_to_make_bank_payment_bnovo
                                    WHERE 
                                        task_key = %(task_key)s;
                                """, {'task_key': row.task_key})
                conn.commit()  

        print(row.task_key)
        print(res)
        #test
        break
        
    
    return res



def lambda_handler(event, context):
    return create_payments_bnovo_after_transformation() 