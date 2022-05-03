user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"
worker_config_node_pool_name = "@@{worker_config_node_pool_name}@@"
less_worker_count = @@{less_worker_count}@@

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

payload = {}

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

### Need to check to see if cluster status is already making updates

url = "https://127.0.0.1:9440/karbon/v1/k8s/clusters/"+k8s_cluster_name

concurrency_request = process_request(url, 'GET', user, password, headers, payload)
concurrency_status = concurrency_request.json()['status']

while concurrency_status == 'kUpdating':
  sleep(15)
  concurrency_request = process_request(url, 'GET', user, password, headers, payload)
  concurrency_status = concurrency_request.json()['status']
  print("Concurrency Check Failed. Alternate Task Already In Progress on {}. Latest Status: {} ").format(k8s_cluster_name,concurrency_status)

### Remove Add Worker

url = "https://127.0.0.1:9440/karbon/v1-alpha.1/k8s/clusters/"+k8s_cluster_name+"/node-pools/"+worker_config_node_pool_name+"/remove-nodes"

payload = {
  "count": less_worker_count
}

r = process_request(url, 'POST', user, password, headers, payload)

task_uuid = r.json()['task_uuid']

print "task_uuid=",task_uuid
