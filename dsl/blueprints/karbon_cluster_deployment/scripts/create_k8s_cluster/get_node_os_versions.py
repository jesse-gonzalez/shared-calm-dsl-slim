user = "admin"
password = base64.b64decode('@@{enc_pc_creds}@@')

def process_request(url, method, user, password, headers, payload=None):
    r = urlreq(url, verb=method, auth="BASIC", user=user, passwd=password, params=payload, verify=False, headers=headers)
    return r

url = "https://127.0.0.1:9440/karbon/acs/image/list"
headers = {'Accept': 'application/json', 'Content-Type': 'application/json'}
url_method = "GET"

r = process_request(url, url_method, user, password, headers)

version_list = []
for version in r.json():
    if version['status'] == 'Downloaded':
        version_list.append(version['version'])

print ','.join(sorted(version_list, key=unicode.lower, reverse=True))
