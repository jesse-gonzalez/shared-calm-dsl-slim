user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"

url = "https://127.0.0.1:9440/karbon/v1/k8s/clusters/"+k8s_cluster_name

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

payload = {}

r = process_request(url, 'GET', user, password, headers, payload)

for worker_config_node_pool_name in r.json()['worker_config']['node_pools']:
  print "worker_config_node_pool_name=",worker_config_node_pool_name
