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


def export_data(bucket_name, data_path, data):
    GOOGLE_APPLICATION_CREDENTIALS = 'flaskapicsv-e0a051a4392b.json'
    with open(GOOGLE_APPLICATION_CREDENTIALS) as source:
        info = json.load(source)
    storage_credentials = service_account.Credentials.from_service_account_info(
        info)
    client = storage.Client(credentials=storage_credentials)
    bucket = client.get_bucket(bucket_name)
    data_blob = bucket.blob(data_path)
    data_blob.upload_from_string(
        data.to_csv(header=True, index=False), 'text/csv')


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
    data_dowloaded_df = pd.read_csv(StringIO(data_str))
    return data_dowloaded_df
# --------------------------------------


@app.route('/', methods=['POST'])
def csv():
    try:
        rules = 'Les inputs sont : \n--status: import/export/export_multiples/add_line\n--import->\n--export->importance(YES/NO)/id(int)\n--export_multiple->importance(YES,NO,YES...)/id(1,3,1,2,...)'
        inputs = dict(request.form)
        if inputs['status'] not in ['import', 'export', 'export_multiple', 'add_line']:
            return(rules)

        if inputs['status'] == 'import':
            df = import_data(bucket_name, data_path)
            df = df[df.IMPORTANT.isna()][['ENGLISH', 'FRENCH', 'THEME','INTERVAL']]
            return str(df.to_dict())
        elif inputs['status'] == 'export':
            df = import_data(bucket_name, data_path)
            ids = df.ID.unique().tolist()
            if not int(inputs['id']) in ids:
                return 'The ID is not in the database.'
            df.at[int(inputs['id']), 'IMPORTANT'] = inputs['importance']
            export_data(bucket_name, data_path, df)
            return 'The dataframe has been updated in the line '+str(inputs['id'])
        elif inputs['status'] == 'export_multiple':
            inputs_ids = inputs['id'].split(',')
            inputs_importances = inputs['importance'].split(',')
            df = import_data(bucket_name, data_path)
            ids = df.ID.unique().tolist()
            for k in range(len(inputs_ids)):
                df.at[int(inputs_ids[k]), 'IMPORTANT'] = inputs_importances[k]
            export_data(bucket_name, data_path, df)
            return 'The dataframe has been updated in the lines:'+' '.join(inputs_ids)
        elif inputs['status'] == 'add_line':
            df = import_data(bucket_name, data_path)
            df2 = pd.DataFrame({'ENGLISH': [inputs['english']], 'FRENCH': [inputs['french']], 'ID': [
                               len(df)], 'IMPORTANT': [inputs['importance']], 'THEME': [inputs['theme']]})
            df = df.append(df2, ignore_index=True)
            export_data(bucket_name, data_path, df)
            return 'A new line has been added.'
    except Exception as e:
        return str(e)


if __name__ == '__main__':
    app.run(host='127.0.0.1', port=8080, debug=True)
