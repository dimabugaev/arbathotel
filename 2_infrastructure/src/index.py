# import json

# def lambda_handler(event, context):
#     print("Hello from Lambda!")


#     responseObj = {}
#     responseObj["statusCode"] = 200
#     responseObj["headers"] = {}
#     responseObj["headers"]["Content-Type"] = 'application/json'
#     responseObj['body'] = json.dumps('Hello from Lambda!')
#     return responseObj

import psycopg2
import json

endpoint = 'dev.coxuw68luhb8.eu-central-1.rds.amazonaws.com'
username = 'dev'
password = 'rootroot'
database_name = 'dev_arbathotel'

connection = psycopg2.connect(host=endpoint, database=database_name, user=username, password=password)

def lambda_handler(event, context):
    cursor = connection.cursor()
    
    cursor.execute("""SELECT 
                        id, 
                        hotel_name 
                      FROM 
                        operate.hotels""")
    
    #rows = cursor.fetchall()
    
    bodyDict = {}
    bodyDict["hotels"] = cursor.fetchall()
    
    cursor.execute("""SELECT 
                        id, 
                        item_name 
                      FROM 
                        operate.report_items""")
                        
    bodyDict["report_items"] = cursor.fetchall()
    
    responseObj = {}
    responseObj["statusCode"] = 200
    responseObj["headers"] = {}
    responseObj["headers"]["Content-Type"] = 'application/json'
    #responseObj['body'] = {}
    #responseObj['body']['hotels'] = json.dumps(rows)
    responseObj['body'] = json.dumps(bodyDict)

    #print(responseObj)

    return responseObj

#handler()