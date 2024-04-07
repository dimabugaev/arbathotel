import my_utility
import json

def lambda_handler(event, context):
    conn = my_utility.get_db_connection()
    cursor = conn.cursor()
    cert_name = event['cert_name']
    if not cert_name:
        cert_name = ''

    print(cert_name)   
    print(type(cert_name)) 

    cursor.execute("""
        with plan as( 
            select 
                s.id source_id,
                period_plan.period_month,
                s.source_type,
                operate.end_of_month(period_plan.period_month) end_period
            from operate.sources s,
                operate.get_date_period_table_fnc(s.source_data_begin, (current_date - interval '1 day')::Date) period_plan
            where 
                s.source_data_begin is not null and s.source_type = 3 and s.source_username = %(cert_name)s)

        select
            p.source_id,
            to_char(coalesce(f.loaded_date, p.period_month),'dd.MM.yyyy') as datefrom,
            to_char(case 
                when p.period_month = date_trunc('month', (current_date - interval '1 day'))::Date then
                    (current_date - interval '1 day')::Date 
                else
                    p.end_period
            end,'dd.MM.yyyy') as dateto
        from 
            plan p left join banks_raw.loaded_data_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.loaded_date < p.end_period;
    """, {'cert_name': cert_name})
    
    my_plan = cursor.fetchall()


    result_list = []
    columns = [desc[0] for desc in cursor.description]
    for row in my_plan:
        dict_element = dict(zip(columns, row))
        result_list.append(dict_element)

    cursor.close()
    conn.close()

    return json.loads(json.dumps(result_list, indent=4, default=str))