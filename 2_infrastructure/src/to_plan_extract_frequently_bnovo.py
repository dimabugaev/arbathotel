import my_utility
import json

def lambda_handler(event, context):

    
    query_statment = """
                        with plan as( 
                        select 
                            s.id source_id,
                            current_date as period_month,
                            s.source_type,
                            date_trunc('month', (current_date - interval '1 month'))::Date past_period,
                            date_trunc('month', current_date)::Date current_period
                        from operate.sources s
                        where 
                            s.source_data_begin is not null and s.source_type = 2)

                        select distinct
                            '' as sid,
                            p.source_id
                        from 
                            plan p;
                    """

    conn = my_utility.get_db_connection()
    cursor = conn.cursor()

    cursor.execute(query_statment)
    
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