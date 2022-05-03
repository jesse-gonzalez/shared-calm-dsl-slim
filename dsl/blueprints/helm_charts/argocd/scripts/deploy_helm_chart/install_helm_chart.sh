WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

## configure admin user
ARGOCD_USER=@@{Argocd User.username}@@
ARGOCD_PASS=@@{Argocd User.secret}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep @@{namespace}@@
then
	echo "Creating namespace ${NAMESPACE}"
	kubectl create namespace ${NAMESPACE}
fi

# this step will configure argocd with ingress tls enabled and self-signed certs managed by cert-manager
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install ${INSTANCE_NAME} argo/argo-cd \
	--namespace ${NAMESPACE} \
	--set installCRDs=false \
	--set server.ingress.enabled=true \
	--set server.ingress.https=true \
	--set-string server.ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
	--set-string server.ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
	--set-string server.ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=true \
	--set server.ingress.hosts[0]="${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}" \
	--set server.ingress.tls[0].hosts[0]=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
	--set server.ingress.tls[0].secretName=${INSTANCE_NAME}-npio-tls \
	--set server.ingress.hosts[1]="${INSTANCE_NAME}.${WILDCARD_INGRESS_DNS_FQDN}" \
	--set server.ingress.tls[1].hosts[0]=${INSTANCE_NAME}.${WILDCARD_INGRESS_DNS_FQDN} \
	--set server.ingress.tls[1].secretName=${INSTANCE_NAME}-wildcard-tls \
	--set server.extraArgs[0]="--insecure" \
	--wait

## -- Bcrypt hashed admin password
## Argo expects the password in the secret to be bcrypt hashed. You can create this hash with
## `htpasswd -nbBC 10 "" $ARGO_PWD | tr -d ':\n' | sed 's/$2y/$2a/'`
## argocdServerAdminPassword: ""

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/part-of=argocd -n ${NAMESPACE}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

echo "Navigate to https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} via browser to access instance

Alternatively, if DNS wildcard domain configured, navigate to https://${INSTANCE_NAME}.${WILDCARD_INGRESS_DNS_FQDN}

After reaching the UI the first time you can login with username: admin and the password will be the
name of the server pod. You can get the pod name by running:

kubectl get pods -l app.kubernetes.io/name=argocd-server -o name | cut -d'/' -f 2"

TEMP_ADMIN_PASS=$(kubectl get pods -l app.kubernetes.io/name=argocd-server -n ${NAMESPACE} | cut -d'/' -f 2)

echo "username: admin, password: ${TEMP_ADMIN_PASS}"
