user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"
worker_config_node_pool_name = "@@{worker_config_node_pool_name}@@"
autoscaler_enabled = "@@{autoscaler_enabled}@@"

# exit out if autoscaler_enabled not true.
if autoscaler_enabled == "false":
  print "Skipping task to enable Karbon_Autoscaler category - autoscaler_enabled is set to false"
  exit(0)

def process_request(url, method, user, password, headers, payload=None):
  r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
  return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

payload = {"length":500}

base_url = "https://"+pc_instance_ip+":"+pc_instance_port

# List Worker VMs from Karbon Cluster

url = base_url+"/karbon/v1-beta.1/k8s/clusters/"+k8s_cluster_name+"/node-pools/"+worker_config_node_pool_name
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "GET"

worker_json_request = process_request(url, url_method, user, password, headers, json.dumps(payload))
worker_node_vms = worker_json_request.json()


# Get Worker VM Details from Prism Central

url = base_url + "/api/nutanix/v3/vms/list"
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "POST"

vms_json_request = process_request(url, url_method, user, password, headers, json.dumps(payload))
vm_list_json = vms_json_request.json()

# Loop through each available worker VM, get uuid and update category
for vm in vm_list_json['entities']:
  for worker_node in worker_node_vms['nodes']:
    if (vm['spec']['name'] == worker_node['hostname']):
      vm_json = vm

      # remove status section and add categories section prior to PUT
      del vm_json['status']
      vm_json['metadata']['categories']['Karbon_AutoScaler'] = "Enabled"
      vm_json['metadata']['categories']['Karbon_CoolDown'] = "Enabled"

      #print "Categories: " + json.dumps(vm_json['metadata']['categories'])
      #print "VM JSON: " + json.dumps(vm_json)

      # update category on vm
      url = base_url + "/api/nutanix/v3/vms/" + str(vm_json['metadata']['uuid'])
      url_method = "PUT"
      category_json_request = process_request(url, url_method, user, password, headers, json.dumps(vm_json))

      #print "Response Status: " + str(category_json_request.status_code)
      print "Response: ", category_json_request.json()
