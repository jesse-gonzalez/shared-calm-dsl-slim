#

STRESS_NAMESPACE="stress"

K8S_CLUSTER_NAME="@@{k8s_cluster_name}@@"

# set current context to cluster we're actively working with.
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/$K8S_CLUSTER_NAME.cfg
kubectl config use-context $K8S_CLUSTER_NAME-context

# delete kubectl stress namespace if it does exist
[ "$(shell kubectl get ns $STRESS_NAMESPACE -o jsonpath='{.status.phase}')" == "Active" ] || (kubectl delete namespace $STRESS_NAMESPACE)
