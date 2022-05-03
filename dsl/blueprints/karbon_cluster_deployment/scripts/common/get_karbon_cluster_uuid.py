url = "https://127.0.0.1:7050/acs/k8s/cluster/list"
user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

payload = {}

r = process_request(url, 'POST', user, password, headers, payload)

print r.json()

for cluster in r.json():
    if cluster['cluster_metadata']['name'] == '@@{k8s_cluster_name}@@':
        print "karbon_cluster_uuid=", cluster['cluster_metadata']['uuid']
