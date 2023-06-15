import my_utility
import csv

def upload_data_to_rds():
    source_data = my_utility.get_email_and_storage_data()
    s3client = source_data['s3client']
    source_bucket = source_data['s3_bucket_for_attachments']
    source_prefix = 'dev/usb-report/income/'
    destination_prefix = 'dev/usb-report/done/'

    conn = my_utility.get_db_connection()
    cursor = conn.cursor()

    column_mapping = {
        0: 'account',
        1: 'draw_date',
        2: 'operation_date',
        3: 'operation_code',
        4: 'bank_corr_bic',
        5: 'bank_corr_account',
        6: 'bank_corr_name',
        7: 'corr_account',
        8: 'correspondent',
        9: 'doc_number',
        10: 'doc_data',
        11: 'debet',
        12: 'credit',
        13: 'rub_cover',
        14: 'code',
        15: 'description',
        16: 'corr_inn',
        17: 'paiment_order'
    }

    permanent_table_name = 'banks_raw.ucb_payments'
    primary_key_fields = ['account', 'doc_number', 'operation_code', 'doc_data', 'debet', 'credit', 'corr_account']

    temp_table_name = 'temp_table_ucb_reports'

    create_temp_table_query = "CREATE TEMP TABLE {table_name} AS SELECT * FROM {permanent_table} WHERE FALSE;".format(table_name=temp_table_name, permanent_table=permanent_table_name)
    cursor.execute(create_temp_table_query)

    s3_objects = s3client.list_objects_v2(Bucket=source_bucket, Prefix=source_prefix)['Contents']
    for s3_object in s3_objects:

        s3_response = s3client.get_object(Bucket=source_bucket, Key=s3_object['Key'])
        csv_data = s3_response['Body'].read().decode('cp1251').splitlines()    
        csv_reader = csv.reader(csv_data, delimiter=';')
        header = next(csv_reader)
        
        for row in csv_reader:
            insert_query = "INSERT INTO {table_name} (".format(table_name=temp_table_name)
            values = []

            for index, column_name in column_mapping.items():
                insert_query += "{column_name},".format(column_name=column_name)
                values.append(row[index])

            insert_query = insert_query.rstrip(',') + ") VALUES ({placeholders});".format(placeholders=','.join(['%s'] * len(column_mapping)))
            cursor.execute(insert_query, values)

    
    delete_query = """
        DELETE FROM {permanent_table}
        WHERE ({where_clause});
        """.format(permanent_table=permanent_table_name,
            where_clause=' AND '.join(
                '{column_name} IN (SELECT {column_name} FROM {temp_table})'.format(
                    column_name=column_name,
                    temp_table=temp_table_name
                )for column_name in primary_key_fields
            ))



    cursor.execute(delete_query)

    transfer_query = """
        INSERT INTO {permanent_table} ({column_list})
        SELECT {column_list}
        FROM {temp_table};
    """.format(permanent_table=permanent_table_name, temp_table=temp_table_name, column_list=','.join(column_mapping.values()))
    cursor.execute(transfer_query)

    # Фиксация изменений в PostgreSQL
    conn.commit()
    cursor.close()
    conn.close()

    for s3_object in s3_objects:
        destination_key = destination_prefix + s3_object['Key'].split('/')[-1]
        s3client.copy_object(Bucket=source_bucket, Key=destination_key, CopySource={'Bucket': source_bucket, 'Key': s3_object['Key']})
        #s3client.delete_object(Bucket=source_bucket, Key=s3_object['Key'])


    print('Данные успешно обработаны и записаны в PostgreSQL таблицу.')




def lambda_handler(event, context):
    upload_data_to_rds()