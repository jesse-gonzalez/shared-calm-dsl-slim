# set current context to cluster we're actively working with.
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/@@{k8s_cluster_name}@@.cfg
kubectl config use-context @@{k8s_cluster_name}@@-context

# install metrics server
kubectl config set-context --current --namespace=kube-system
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml -n kube-system
kubectl -n kube-system patch deployment metrics-server --type='json' -p '[{"op": "replace","path": "/spec/template/spec/containers/0/args","value": ["--cert-dir=/tmp","--secure-port=443","--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname","--kubelet-use-node-status-port","--kubelet-insecure-tls"]}]'

# wait for metrics server pod to be ready
#kubectl wait -n kube-system --for=condition=Ready pod/$(kubectl get po -l k8s-app=metrics-server -o jsonpath='{.items[].metadata.name}' --namespace=kube-system) --timeout=300s

