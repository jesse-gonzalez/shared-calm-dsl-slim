echo 'apiVersion: v1
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
      - @@{metallb_network_range}@@' > metallb_configmap.yaml

echo "Set KUBECONFIG"
export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

echo "Apply Config Map"
kubectl apply -f metallb_configmap.yaml
