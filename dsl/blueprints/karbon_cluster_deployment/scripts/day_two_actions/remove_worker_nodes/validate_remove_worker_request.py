user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"
worker_config_node_pool_name = "@@{worker_config_node_pool_name}@@"
autoscaler_enabled = "@@{autoscaler_enabled}@@"
# if worker_count (i.e., autoscaler_min_count = 1), then 1 should pass, else fail
less_worker_count = @@{less_worker_count}@@
autoscaler_min_count = @@{worker_count}@@

url = "https://127.0.0.1:9440/karbon/v1-beta.1/k8s/clusters/"+k8s_cluster_name+"/node-pools/"+worker_config_node_pool_name

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

payload = {}

r = process_request(url, 'GET', user, password, headers, payload)

worker_node_pool_count = r.json()['num_instances']

# Print Less Worker Node Count
print("INFO: Less Worker Count Requested: {}").format(less_worker_count)

# Print Current Worker Count
print("INFO: Current Worker Count: {}").format(worker_node_pool_count)

# Print autoscaler_min_count
print("INFO: 'autoscaler_min_count': {}").format(autoscaler_min_count)

# sum of worker nodes minus requested account
total_less_node_count = (worker_node_pool_count - less_worker_count)

# Print Total Requested Count
print("INFO: Sum of Target Less Worker Count: {}").format(total_less_node_count)

# validate whether the total account exceed min count
#if autoscaler_enabled == "true" :

if total_less_node_count >= autoscaler_min_count :
    print("INFO: Removing {} Nodes from existing Karbon Cluster: '{}'. Remaining Count will be {}.").format(less_worker_count,k8s_cluster_name, total_less_node_count)
else:
    print("WARNING: Target Total Number of Node(s): {} will be below minimal nodes required available: {}").format(total_less_node_count,autoscaler_min_count)
    exit(1)
