user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')

def process_request(url, method, user, password, headers, payload=None):
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

url = "https://127.0.0.1:9440/api/nutanix/v3/clusters/list"
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "POST"

payload = {}
r = process_request(url, url_method, user, password, headers, json.dumps(payload))

cluster_list = []
for cluster in r.json()['entities']:
    if ('nodes' in cluster['status']['resources'] and cluster['status']['resources']['nodes']['hypervisor_server_list'][0]['type'] == 'AHV'):
        cluster_list.append(cluster['status']['name'])

print ','.join(sorted(cluster_list, key=unicode.lower)),
