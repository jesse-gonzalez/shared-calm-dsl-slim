pc_user = "admin"
pc_password = base64.b64decode('@@{enc_pc_creds}@@')
pe_user = "admin"
pe_password = base64.b64decode('@@{enc_pe_creds}@@')

def process_request(url, method, user, password, headers, payload=None):
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}

url = "https://127.0.0.1:9440/api/nutanix/v3/clusters/list"
url_method = "POST"

payload = {}
r = process_request(url, url_method, pc_user, pc_password, headers, json.dumps(payload))

for cluster in r.json()['entities']:
    if cluster['status']['name'] == '@@{nutanix_ahv_cluster}@@':
        pe_ip = cluster['status']['resources']['network']['external_ip']

url = "https://" + pe_ip +":@@{pc_instance_port}@@/PrismGateway/services/rest/v2.0/storage_containers"
url_method = "GET"

r = process_request(url, url_method, pe_user, pe_password, headers)

storage_container_list = []
for storage_container in r.json()['entities']:
    storage_container_list.append(storage_container['name'])

print ','.join(sorted(storage_container_list, key=unicode.lower)),
