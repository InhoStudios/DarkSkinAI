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

def indexDescendants(entity, indentationLevel):
    entityTitle = entity['title']
    returnString = entityTitle + "\n"
    indent = "    "
    descendants = entity['descendants']
    for descendant in descendants:
        returnString = returnString + indent * indentationLevel + indexDescendants(descendant, indentationLevel + 1)
    return returnString

if __name__ == '__main__':
    r = requests.post(token_endpoint, data=payload, verify=False).json();
    token = r['access_token']
    useFlexisearch = 'true'
    query = 'eczema'
    flatResults = 'false'

    uri = f'https://id.who.int/icd/entity/search?q={query}&useFlexisearch={useFlexisearch}&flatResults={flatResults}'

    headers = {'Authorization': 'Bearer ' + token,
               'Accept': 'application/json',
               'Accept-Language': 'en',
               'API-Version': 'v2'
               }

    print(headers)

    r = requests.post(uri, headers=headers, verify=False)

    print(r.text)

    r_dict = json.loads(r.text)

    titles = [];

    str = ""

    for entity in r_dict['destinationEntities']:
        str = str + indexDescendants(entity, 1)
        titles = str.split("\n")

    print(str)
