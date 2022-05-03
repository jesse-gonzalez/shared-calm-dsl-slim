
echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

echo "Install Ingress Nginx"
kubectl create namespace ingress-nginx
kubectl config set-context --current --namespace=ingress-nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx \
	ingress-nginx/ingress-nginx \
	--set rbac.create=true \
	--set controller.replicaCount=3 \
	--set controller.config.proxy-body-size=0 \
	--set controller.config.proxy-request-buffering="off" \
	--set controller.config.proxy-read-timeout=1800 \
	--set controller.config.proxy-send-timeout=1800 \
	--set force-ssl-redirect=true \
	--set ingressClassResource.default=true \
	--namespace=ingress-nginx \
	--wait

