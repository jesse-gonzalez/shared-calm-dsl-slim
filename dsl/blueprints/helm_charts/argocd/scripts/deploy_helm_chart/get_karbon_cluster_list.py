url = "https://127.0.0.1:9440/karbon/v1-beta.1/k8s/clusters"

user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

payload = {}

r = process_request(url, 'GET', user, password, headers, payload)

cluster_list = []
for cluster in r.json():
    cluster_list.append(cluster['name'])

print ', '.join(cluster_list),
