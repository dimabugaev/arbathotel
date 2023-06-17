import my_utility
import json

def lambda_handler(event, context):
    conn = my_utility.get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        with plan as( 
            select 
                s.id source_id,
                period_plan.period_month,
                s.source_type,
                date_trunc('month', (current_date - interval '1 month'))::Date past_period,
                date_trunc('month', current_date)::Date current_period
            from operate.sources s,
                operate.get_date_period_table_fnc(s.source_data_begin, current_date) period_plan
            where 
                s.source_data_begin is not null and s.source_type = 2)

        select
            '' as sid,
            p.source_id,
            extract('year' from p.period_month)::int as year,
            extract('month' from p.period_month)::int as month
        from 
            plan p left join bnovo_raw.balance_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.period_month = p.past_period or f.period_month = p.current_period;
     """)
    
    my_plan = cursor.fetchall()


    result_list = []
    columns = [desc[0] for desc in cursor.description]
    for row in my_plan:
        dict_element = dict(zip(columns, row))
        if isinstance(event, dict):
            dict_element['sid'] = event.get(str(row[1]), '')
        result_list.append(dict_element)

    cursor.close()
    conn.close()

    return json.loads(json.dumps(result_list, indent=4, default=str))