import my_utility
import imaplib

def get_data_from_email():
    email_cred = my_utility.get_email_and_storage_data()
    email = str(email_cred['email_address'])
    password = email_cred['password']
    tagret_bucket = email_cred['s3_bucket_for_attachments']

    imap_addr = 'imap.'+ email[email.find('@') + 1:]

    imap = imaplib.IMAP4_SSL(imap_addr)

    try:
        imap.login(email, password)
    except Exception as e:
        print(f"Unable to login due to {e}")
    else:
        print("Login successfully")

    print(imap) 
    print(tagret_bucket)   

def lambda_handler(event, context):
    get_data_from_email()
    