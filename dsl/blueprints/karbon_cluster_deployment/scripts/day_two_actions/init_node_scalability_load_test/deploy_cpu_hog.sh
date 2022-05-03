#

STRESS_NAMESPACE="stress"

K8S_CLUSTER_NAME="@@{k8s_cluster_name}@@"

# set current context to cluster we're actively working with.
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/$K8S_CLUSTER_NAME.cfg
kubectl config use-context $K8S_CLUSTER_NAME-context

# create kubectl stress namespace if it doesn't exist
[ "$(kubectl get ns $STRESS_NAMESPACE -o jsonpath='{.status.phase}')" == "Active" ] || (kubectl create namespace $STRESS_NAMESPACE)

# set kubectl namespace to target namespace
kubectl config set-context --current --namespace=$STRESS_NAMESPACE

# configure hog yaml file based on inputs
# this will create a single pod and allocate max of 1 CPU (1000m), about 50% of what is current limit
echo 'apiVersion: apps/v1
kind: DaemonSet
metadata:
  labels:
    app: hog
  name: hog
spec:
  selector:
    matchLabels:
      app: hog
  template:
    metadata:
      labels:
        app: hog
    spec:
      containers:
      - image: vish/stress
        name: stress
        resources:
          requests:
            cpu: "0.5"
        args:
        - -cpus
        - "6"' > hog.yaml

# create hog ds
kubectl create -f hog.yaml

# validate hog ds
kubectl get ds
kubectl describe ds hog
kubectl get ds hog -o yaml

# wait for hog pods to be ready
kubectl wait --for=condition=Ready pod/$(kubectl get po -l app=hog -o jsonpath='{.items[].metadata.name}')

# watch progress of hpa, nodes, pods in one screen
# watch -n .5 "kubectl top nodes && echo "" && kubectl top pods && echo "" && kubectl get hpa,ds,po -o wide"

# watch events in other
# kubectl get events
