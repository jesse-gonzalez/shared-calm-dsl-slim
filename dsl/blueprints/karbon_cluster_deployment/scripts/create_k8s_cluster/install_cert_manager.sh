
echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

echo "Install Cert-Manager"
kubectl create namespace cert-manager
kubectl config set-context --current --namespace=cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
	--namespace cert-manager \
	--set installCRDs=true \
	--wait

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=cert-manager

echo "Configure Cert-Manager Self-Signed Cluster Issuer"

echo 'apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-cluster-issuer
spec:
  selfSigned: {}' > self-signed-clusterissuer.yaml

# configure default self-signed certificate cluster issuers
kubectl create -f self-signed-clusterissuer.yaml --save-config
