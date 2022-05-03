K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name ${K8S_CLUSTER_NAME} > ~/${K8S_CLUSTER_NAME}.cfg

export KUBECONFIG=~/${K8S_CLUSTER_NAME}.cfg


if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep metallb-system
then
	echo "Creating namespace metallb-system"
	kubectl create namespace metallb-system
fi


echo "Install MetalLB"
# create metallb configmap and secret with layer2 details
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - @@{metallb_network_range}@@
EOF

#kubectl apply -f $HOME/${K8S_CLUSTER_NAME}_metallb-configmap.yaml

# install metallb via helm
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm upgrade --install metallb bitnami/metallb \
	--namespace metallb-system \
	--set controller.rbac.create=true	\
	--set existingConfigMap=config \
	--wait

helm status metallb -n metallb-system

## setting images to 0.9.4 cause 0.12.1 latest seems to be broken and failing to assign IPs
kubectl set image -n metallb-system deployments/metallb-controller *=docker.io/bitnami/metallb-controller:0.9.4
kubectl set image -n metallb-system daemonset/metallb-speaker *=docker.io/bitnami/metallb-speaker:0.9.4

#kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=metallb -n metallb-system

