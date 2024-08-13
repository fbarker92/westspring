import csv
import requests
import msal
from flask import Flask, render_template, request
import logging
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

# Configuration
CLIENT_ID = '7e05a6ec-9b94-48bf-9879-70b8e7f0837c'
CLIENT_SECRET = 'Bmg8Q~g.SaWiaZccHCmWM-J6xBqBcRmiWTfmCbKL'
TENANT_ID = '46799983-f274-4dcf-b610-7b7898d288c0'
AUTHORITY = f'https://login.microsoftonline.com/{TENANT_ID}'
SCOPE = ["https://graph.microsoft.com/.default"]
GRAPH_API_ENDPOINT = 'https://graph.microsoft.com/v1.0/'

def get_msal_app():
    return msal.ConfidentialClientApplication(CLIENT_ID, authority=AUTHORITY, client_credential=CLIENT_SECRET)

def get_access_token():
    app = get_msal_app()
    result = app.acquire_token_silent(SCOPE, account=None)
    if not result:
        result = app.acquire_token_for_client(scopes=SCOPE)
    return result['access_token']

def read_tenants_from_csv():
    tenants = []
    with open('tenants.csv', mode='r') as file:
        reader = csv.DictReader(file)
        tenants = list(reader)
    return tenants

def fetch_available_domains(access_token):
    response = requests.get(f"{GRAPH_API_ENDPOINT}/domains", headers={'Authorization': 'Bearer ' + access_token})
    if response.status_code == 200:
        return response.json().get('value', [])
    return []

def fetch_groups(access_token):
    groups = []
    url = f"{GRAPH_API_ENDPOINT}/groups?$select=id,displayName,mailEnabled,securityEnabled,groupTypes&$top=999"
    headers = {'Authorization': 'Bearer ' + access_token}

    while url:
        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            data = response.json()
            groups.extend(data.get('value', []))
            url = data.get('@odata.nextLink')
        else:
            print(f"Failed to fetch groups: {response.json()}")
            break

    categorized_groups = {
        'security_groups': [g for g in groups if g.get('securityEnabled', False) and not g.get('mailEnabled', False)],
        'mail_enabled_security_groups': [g for g in groups if g.get('mailEnabled', False) and g.get('securityEnabled', False)],
        'distribution_groups': [g for g in groups if g.get('mailEnabled', False) and not g.get('securityEnabled', False) and 'Unified' not in g.get('groupTypes', [])],
        'm365_groups': [g for g in groups if 'Unified' in g.get('groupTypes', [])]
    }
    return categorized_groups


def fetch_licenses(access_token):
    response = requests.get(f"{GRAPH_API_ENDPOINT}/subscribedSkus", headers={'Authorization': 'Bearer ' + access_token})
    return response.json().get('value', [])

def create_user_in_microsoft_365(user_data, access_token):
    # Logging
#    logging.debug("Sending request to MS Graph API with body: %s", body)
#    response = requests.post(f'https://graph.microsoft.com/v1.0/users', json=body, headers=headers)
#    logging.debug("Received response: %s", response.json())
    # /Loggin
    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': 'application/json'
    }
    body = {
        "accountEnabled": True,
        "displayName": user_data['display_name'],
        "mailNickname": user_data['username'].split('@')[0],  # Split username to create a mail nickname
        "userPrincipalName": user_data['userprincipalname'],
        "passwordProfile" : {
            "forceChangePasswordNextSignIn": True,
            "password": user_data['password']
        }
    }
    response = requests.post(f'https://graph.microsoft.com/v1.0/users', json=body, headers=headers)
    if response.status_code != 201:  # HTTP 201 means Created
        return {"error": {"message": f"Failed to create user: {response.json()}"}}  # Ensures error key exists
    return response.json()



@app.route('/')
def form():
    tenants = read_tenants_from_csv()
    access_token = get_access_token()
    domains = fetch_available_domains(access_token) if access_token else []
    groups = fetch_groups(access_token) if access_token else []
    licenses = fetch_licenses(access_token) if access_token else []
    default_domain = domains[0]['id'] if domains else None

    return render_template('form.html', tenants=tenants, available_domains=domains, default_domain=default_domain, all_groups=groups, licenses=licenses)

@app.route('/submit_form', methods=['POST'])
def submit_form():
    tenant_id = request.form['tenant_select']
    user_data = {
        'first_name': request.form['first_name'],
        'last_name': request.form['last_name'],
        'display_name': request.form['display_name'],
        'job_title': request.form['job_title'],
        'department': request.form['department'],
        'mobile_number': request.form['mobile_number'],
        'office_number': request.form['office_number'],
        'username': request.form['username'],
        'userprincipalname': request.form['username'] + '@' + request.form['domain'],
        'password': request.form['password'],
        'domain': request.form['domain']
    }
    group_ids = request.form.getlist('groups')
    access_token = get_access_token()
    user_creation_response = create_user_in_microsoft_365(user_data, access_token)
    if 'error' in user_creation_response:
        return f"Error: {user_creation_response['error']['message']}", 400
    # Handle user creation and group assignment logic here
    print(f"Creating user with {user_data} in tenant {tenant_id}"),
    print("{userprincipalname}")
    # Example: Call function to create user and assign to groups

    print(f"User created with {user_data} in tenant {tenant_id}")
    return "Form submitted successfully!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)