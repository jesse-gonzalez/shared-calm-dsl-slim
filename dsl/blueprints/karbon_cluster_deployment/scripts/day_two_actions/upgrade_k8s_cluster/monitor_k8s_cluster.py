#https://<PC IP>:9440/karbon/acs/k8s/cluster/<CLUSTER_UUID>/k8s_upgrade

user = "@@{Prism Central User.username}@@"
password = "@@{Prism Central User.secret}@@"
k8s_cluster_name = "@@{k8s_cluster_name}@@"
task_uuid = "@@{task_uuid}@@"

url = "https://127.0.0.1:9440/karbon/v1-alpha.1/k8s/clusters/"+k8s_cluster_name+"/tasks/"+task_uuid

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}
payload = {}

r = process_request(url, 'GET', user, password, headers, payload)
task_status = r.json()['status']

while task_status == 'kRunning':
  sleep(15)
  r = process_request(url, 'GET', user, password, headers, payload)
  task_status = r.json()['status']
  print "Task Status: ", task_status

if task_status == "kSucceeded":
  print "Task completed successfully"
  exit(0)
else:
  print "Task failed"
  exit(1)
