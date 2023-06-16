import my_utility

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
            extract('year' from p.period_month) as year,
            extract('month' from p.period_month) as month
        from 
            plan p left join bnovo_raw.balance_by_period f 
                on p.period_month = f.period_month and p.source_id = f.source_id 
        where
            f.source_id is null or f.period_month = p.past_period or f.period_month = p.current_period;
     """)
    
    my_plan = cursor.fetchall()
    cursor.close()
    conn.close()

    return my_plan