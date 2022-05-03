user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')
k8s_cluster_name = "@@{k8s_cluster_name}@@"

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

payload = {}

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

### Need to get karbon cluster uuid

url = "https://127.0.0.1:9440/karbon/v1/k8s/clusters/"+k8s_cluster_name

karbon_cluster_request = process_request(url, 'GET', user, password, headers, payload)
karbon_cluster_uuid = karbon_cluster_request.json()['uuid']

### Get Compatible Version

url = "https://127.0.0.1:9440/karbon/acs/k8s/cluster/"+karbon_cluster_uuid+"/k8s_upgrade/versions"

compatible_versions_request = process_request(url, 'GET', user, password, headers, payload)

current_version = compatible_versions_request.json()['cur_version']

compatible_version_list = []
for version in compatible_versions_request.json()['compatible_versions']:
    if version != current_version:
        compatible_version_list.append(version)

print ', '.join(sorted(compatible_version_list, key=unicode.lower))
