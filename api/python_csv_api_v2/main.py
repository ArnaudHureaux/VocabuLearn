from flask import Flask, request
import pandas as pd
from io import StringIO
from google.cloud import storage
from google.oauth2 import service_account
import json

bucket_name = 'flaskapicsv.appspot.com'
data_path = 'data.csv'
app = Flask(__name__)
# --------------------------------------


def import_data(bucket_name, data_path):
    GOOGLE_APPLICATION_CREDENTIALS = 'flaskapicsv-e0a051a4392b.json'
    with open(GOOGLE_APPLICATION_CREDENTIALS) as source:
        info = json.load(source)
    storage_credentials = service_account.Credentials.from_service_account_info(
        info)
    client = storage.Client(credentials=storage_credentials)
    bucket = client.get_bucket(bucket_name)
    data_blob = bucket.blob(data_path)
    data_str = data_blob.download_as_text()
    data_dowloaded_df = pd.read_csv(
        StringIO(data_str))
    return data_dowloaded_df
# --------------------------------------


@app.route('/', methods=['POST'])
def csv():
    try:
        inputs = dict(request.form)
        langues = ['PORTUGAIS', 'ENGLISH', 'CHINESE', 'KOREAN', 'JAPAN', 'FRENCH',
                   'HINDI', 'DEUTSCH', 'SPAIN', 'POLONAIS', 'TURC', 'RUSSIAN', 'ARABE', 'DANOIS']
        if ((inputs['speak'] not in langues) | (inputs['learn'] not in langues)):
            return 'Les langues sélectionnés doivent appartenir à :'+str(langues)
        else:
            data_path = data_path = 'dataset/' + \
                inputs['learn']+'/'+inputs['learn']+'_'+inputs['speak']+'.csv'
            df = import_data(bucket_name, data_path)
            return str(df.to_dict())

    except Exception as e:
        return str(e)


@app.route('/', methods=['GET'])
def get():
    return 'Ceci est l\'API de l\'application VocabuLearn (disponible sous IOs et Android)!'


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
