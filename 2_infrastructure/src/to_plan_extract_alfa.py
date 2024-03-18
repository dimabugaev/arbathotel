import my_utility
import json
import requests

def get_token(conn, client_id, client_secret, refresh_token):
    session = requests.Session()
    url = "https://sandbox.alfabank.ru/oidc/token"

    session.headers.update({
        "Content-Type": "application/x-www-form-urlencoded",
        "Accept": "application/json" 
    })

    payload = {'grant_type': 'refresh_token',
            'refresh_token': refresh_token,
            'client_id': client_id,
            'client_secret': client_secret}

    token = ''

    with session.post(url, data=payload) as response:
        result = json.loads(response.text)
        print(result)
        with conn.cursor() as cursor:
            cursor.execute("""update banks_raw.alfa_params
                              set
                                refresh_token = %(refresh_token)s 
                              where client_id = %(client_id)s
                           """, {'client_id': client_id, 'refresh_token': result['refresh_token']})
            token = result['access_token']
        conn.commit()
    return token

def token_for_client_id(conn, tokens_cash, client_id):

    token = tokens_cash.get(client_id)
    if token:
        return token

    cursor = conn.cursor()
    cursor.execute("""select 
                        ap.client_secret as client_secret,
                        ap.refresh_token as refresh_token
                    from banks_raw.alfa_params ap 
                    where ap.client_id = %(client_id)s
                    limit 1""", {'client_id': client_id})
    
    params = cursor.fetchone()
    return get_token(conn, client_id, params[0], params[1])


def lambda_handler(event, context):
    conn = my_utility.get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        with plan as( 
            select 
                s.id source_id,
                s.source_password client_id,
                period_plan.period_month,
                s.source_type,
                operate.end_of_month(period_plan.period_month) end_period
            from operate.sources s,
                operate.get_date_period_table_fnc(s.source_data_begin, (current_date - interval '1 day')::Date) period_plan
            where 
                s.source_data_begin is not null and s.source_type = 5)

        select
            p.source_id,
            p.client_id,
            to_char(coalesce(f.loaded_date, p.period_month),'dd.MM.yyyy') as datefrom,
            to_char(case 
                when p.period_month = date_trunc('month', (current_date - interval '1 day'))::Date then
                    current_date::Date
                else
                    (p.end_period + interval '1 day')::Date
            end, 'dd.MM.yyyy')  as dateto
        from 
            plan p left join banks_raw.loaded_data_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.loaded_date < p.end_period;
     """)
    
    my_plan = cursor.fetchall()

    tokens = {}
    result_list = []
    columns = [desc[0] for desc in cursor.description]
    for row in my_plan:
        dict_element = dict(zip(columns, row))
        dict_element['token'] = token_for_client_id(conn, tokens, dict_element['client_id'])
        tokens[dict_element['client_id']] = dict_element['token']
        result_list.append(dict_element)

    cursor.close()
    conn.close()

    return json.loads(json.dumps(result_list, indent=4, default=str))