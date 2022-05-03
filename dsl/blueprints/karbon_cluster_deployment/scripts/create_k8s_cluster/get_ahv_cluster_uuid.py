user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"

def process_request(url, method, user, password, headers, payload=None):
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

url = "https://127.0.0.1:9440/api/nutanix/v3/clusters/list"
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "POST"

payload = {}
r = process_request(url, url_method, user, password, headers, json.dumps(payload))

for cluster in r.json()['entities']:
    if cluster['status']['name'] == '@@{nutanix_ahv_cluster}@@':
        print "prism_element_uuid=", cluster['metadata']['uuid']

