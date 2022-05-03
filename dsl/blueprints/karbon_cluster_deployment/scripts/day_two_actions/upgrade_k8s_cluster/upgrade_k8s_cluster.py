user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')
k8s_cluster_name = "@@{k8s_cluster_name}@@"
karbon_cluster_uuid = "@@{karbon_cluster_uuid}@@"
package_version = "@@{package_version}@@"

def process_request(url, method, user, password, headers, payload=None):
    if (payload != None):
        payload = json.dumps(payload)
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

payload = {
  "upgrade_config": {
    "pkg_version": package_version
  },
  "drain-policy": "kAlways",
  "drain-timeout": "180s"
}

headers = {'Accept': 'application/json', 'Content-Type': 'application/json; charset=UTF-8'}

### Need to check to see if cluster status is already making updates

url = "https://127.0.0.1:9440/karbon/acs/k8s/cluster/"+karbon_cluster_uuid+"/k8s_upgrade"

r = process_request(url, 'POST', user, password, headers, payload)

task_uuid = r.json()['task_uuid']

print "task_uuid=",task_uuid
