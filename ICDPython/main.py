import requests
import credentials
import json

token_endpoint = "https://icdaccessmanagement.who.int/connect/token"
scope = "icdapi_access"
grant_type = "client_credentials"

payload = {"client_id": credentials.client_id,
           "client_secret": credentials.client_secret,
           "scope": scope,
           "grant_type": grant_type}

if __name__ == '__main__':
    r = requests.post(token_endpoint, data=payload, verify=False).json();
    token = r['access_token']
    useFlexisearch = 'true'
    query = 'psoriasis'

    uri = f'https://id.who.int/icd/entity/search?q={query}&useFlexisearch={useFlexisearch}'

    headers = {'Authorization': 'Bearer ' + token,
               'Accept': 'application/json',
               'Accept-Language': 'en',
               'API-Version': 'v2'
               }

    print(headers)

    r = requests.post(uri, headers=headers, verify=False)

    print(r.text)

    r_dict = json.loads(r.text)

    for entity in r_dict['destinationEntities']:
        print(entity)
        print(entity['id'])
        break
