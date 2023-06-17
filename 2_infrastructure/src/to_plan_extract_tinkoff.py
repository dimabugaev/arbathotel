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
                operate.end_of_month(period_plan.period_month) end_period
            from operate.sources s,
                operate.get_date_period_table_fnc(s.source_data_begin, (current_date - interval '1 day')::Date) period_plan
            where 
                s.source_data_begin is not null and s.source_type = 4)

        select
            p.source_id,
            coalesce(f.loaded_date, p.period_month) as datafrom,
            case 
                when p.period_month = date_trunc('month', (current_date - interval '1 day'))::Date then
                    current_date::Date
                else
                    (p.end_period + interval '1 day')::Date
            end as datato
        from 
            plan p left join banks_raw.loaded_data_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.loaded_date < p.end_period;
     """)
    
    my_plan = cursor.fetchall()


    result_list = []
    columns = [desc[0] for desc in cursor.description]
    for row in my_plan:
        dict_element = dict(zip(columns, row))
        result_list.append(dict_element)

    cursor.close()
    conn.close()

    return json.loads(json.dumps(result_list, indent=4, default=str))