user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')

def process_request(url, method, user, password, headers, payload=None):
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

url = "https://127.0.0.1:9440/api/nutanix/v3/subnets/list"
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "POST"

payload = {}
r = process_request(url, url_method, user, password, headers, json.dumps(payload))

network_list = []
for network in r.json()['entities']:
    if network['status']['cluster_reference']['name'] == '@@{nutanix_ahv_cluster}@@':
        network_list.append(network['status']['name'])

print ', '.join(network_list),
