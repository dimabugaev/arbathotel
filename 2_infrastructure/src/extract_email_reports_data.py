import my_utility

def get_data_from_email():
    email_cred = my_utility.get_email_and_storage_data()
    email = str(email_cred['email_address'])
    password = email_cred['password']
    tagret_bucket = email_cred['s3_bucket_for_attachments']

    imap = 'imap.'+ email[email.find('@'):]

    print(imap) 
    print(tagret_bucket)   

def lambda_handler(event, context):
    get_data_from_email()
    