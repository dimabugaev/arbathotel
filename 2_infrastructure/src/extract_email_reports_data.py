import my_utility
import imaplib
import email
import zipfile
import io

def get_type_of_letter(message) -> int:
    template_email_for_acquiring = 'kartcentr@psbank.ru'
    list_of_senders = ['buyanova@1arbat-hotel.ru', 'kartcentr@psbank.ru']
    result = 0

    #print(message['from'])
    #print(message['to'])

    if message['from'].lower() not in list_of_senders:
        return result
    
    if message['from'].casefold().find(template_email_for_acquiring) > -1:
        result = 1
        return result

    for part in message.walk():
        if part.get_content_type() == 'text/plain' or part.get_content_type() == 'text/html':
            body = part.get_payload(decode=True)
            if body.decode('utf-8').casefold().find(template_email_for_acquiring) > -1:
                result = 1 #PSB acquiring 
                break   
        else:
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue

            filename = part.get_filename()
            if filename:
                if filename.find('imbkrumm') > -1 or filename.find('ALMNKZKA') > -1:
                    result = 2 #UCB
                    break    

    return result  


def get_data_from_email():
    email_cred = my_utility.get_email_and_storage_data()
    email_addr = str(email_cred['email_address'])
    password = email_cred['password']
    tagret_bucket = email_cred['s3_bucket_for_attachments']
    s3client = email_cred['s3client'] 

    keys_dict = {1 : 'dev/psb-acquiring/income/', 2 : 'dev/usb-report/income/'}
    

    imap_addr = 'imap.'+ email_addr[email_addr.find('@') + 1:]

    imap = imaplib.IMAP4_SSL(imap_addr)

    try:
        imap.login(email_addr, password)
        imap.select('INBOX')
        _, data = imap.search(None, 'ALL')

        id_list = data[0].split()

        for mail_id in id_list:
            _, raw_data = imap.fetch(mail_id, '(RFC822)' )
            email_message = email.message_from_bytes(raw_data[0][1])
            

            type_of_letter = get_type_of_letter(email_message)
            if type_of_letter == 0:
                continue

            #print(email_message['from'])
            #print(email_message['to'])
            
            for part in email_message.walk():
                # this part comes from the snipped I don't understand yet... 
                if part.get_content_maintype() == 'multipart':
                    continue
                if part.get('Content-Disposition') is None:
                    continue
                
                filename = part.get_filename()

                if filename:

                    if filename.lower().endswith('.zip'):
                        with zipfile.ZipFile(io.BytesIO(part.get_payload(decode=True)), 'r') as zip_ref:
                            for extracted_file in zip_ref.namelist():
                                s3client.put_object(Bucket=tagret_bucket, Key=keys_dict.get(type_of_letter)+extracted_file, Body=zip_ref.read(extracted_file))
                    else: 
                        s3client.put_object(Bucket=tagret_bucket, Key=keys_dict.get(type_of_letter)+filename, Body=part.get_payload(decode=True)
                    )
                    print(filename)

            ###temporary turn off mail cleaning for test lambdas
            imap.store(mail_id, '+FLAGS', '\\Deleted')    
            
        

    except Exception as e:
        print(f"Unexpected error {e}")
    finally:
        imap.expunge()
        imap.close()
        imap.logout()
    


def lambda_handler(event, context):
    get_data_from_email()
    