

#### Connectivity Details

URL:
[https://@@{instance_name}@@.@@{Helm_Jenkins.nipio_ingress_domain}@@](https://@@{instance_name}@@.@@{Helm_Jenkins.nipio_ingress_domain}@@)

Username: admin

Temporary_Password can be found using the following:

`kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo`
