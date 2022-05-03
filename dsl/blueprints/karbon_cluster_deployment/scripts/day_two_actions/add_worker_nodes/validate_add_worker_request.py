user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"
worker_config_node_pool_name = "@@{worker_config_node_pool_name}@@"
addtl_worker_count = @@{addtl_worker_count}@@
autoscaler_enabled = "@@{autoscaler_enabled}@@"
autoscaler_max_count = @@{autoscaler_max_count}@@

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

# Print Additional Worker Node Count
print("INFO: Additional Worker Count Requested: {}").format(addtl_worker_count)

# Print Current Worker Count
print("INFO: Current Worker Count: {}").format(worker_node_pool_count)

# Print autoscaler_max_count
print("INFO: 'autoscaler_max_count': {}").format(autoscaler_max_count)

# sum of existing worker nodes and requested counts
total_add_node_count = (worker_node_pool_count + addtl_worker_count)

# Print Total Requested Count
print("INFO: Sum of Target Add Worker Count: {}").format(total_add_node_count)

# validate whether the total account exceed max count
if autoscaler_enabled == "true" :
    if total_add_node_count <= autoscaler_max_count :
        print("INFO: Adding {} Nodes to existing Karbon Cluster: '{}'. New Total Count will be {}.").format(addtl_worker_count,k8s_cluster_name, total_add_node_count)
    else:
        print("ERROR: Total Number of Node(s) requested: {} will exceed 'autoscaler_max_count' requested: {}").format(total_add_node_count,autoscaler_max_count)
        exit(1)
else:
    print("INFO: Adding {} Nodes to existing Karbon Cluster: '{}'. New Total Count will be {}.").format(addtl_worker_count,k8s_cluster_name, total_add_node_count)
