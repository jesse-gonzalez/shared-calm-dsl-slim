

#### Connectivity Details

URL:
[https://@@{instance_name}@@.@@{Helm_ArgoCd.nipio_ingress_domain}@@](https://@@{instance_name}@@.@@{Helm_ArgoCd.nipio_ingress_domain}@@)

Username: admin

Temporary_Password can be found using the following:

`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo`
