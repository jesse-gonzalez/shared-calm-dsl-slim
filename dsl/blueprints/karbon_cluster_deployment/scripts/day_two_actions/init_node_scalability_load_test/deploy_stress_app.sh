K8S_CLUSTER_NAME="@@{k8s_cluster_name}@@"

#K8S_CLUSTER_NAME="cluster_autoscaling"

HPA_NAMESPACE="stress"

# set current context to cluster we're actively working with.
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/$K8S_CLUSTER_NAME.cfg
kubectl config use-context $K8S_CLUSTER_NAME-context

# create kubectl stress namespace if it doesn't exist
[ "$(kubectl get ns $HPA_NAMESPACE -o jsonpath='{.status.phase}')" == "Active" ] || (kubectl create namespace $HPA_NAMESPACE)

# set kubectl namespace to target namespace
kubectl config set-context --current --namespace=$HPA_NAMESPACE

# configure hog yaml file based on inputs
## based off of https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
## This is a custom docker images that has simple index.php page which performs some CPU intensive computations:

echo 'apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache' > php-apache.yaml


# create php-apache deployment
kubectl create -f php-apache.yaml -n $HPA_NAMESPACE

# validate php-apache deployment
kubectl get deployment php-apache -o yaml -n $HPA_NAMESPACE

# wait for php-apache pods to be ready
kubectl wait --for=condition=Ready pod/$(kubectl get po -l run=php-apache -n $HPA_NAMESPACE -o jsonpath='{.items[].metadata.name}')

# deploy horizontal autoscaler and label
kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10 -n $HPA_NAMESPACE
kubectl label hpa php-apache run=php-apache -n $HPA_NAMESPACE

# validate hpa
kubectl get hpa php-apache -o yaml -n $HPA_NAMESPACE

# generate load using alternative container. Open 3 terminals

# watch events in first terminal
# kubectl get events -w

# generate load.
kubectl run load-generator --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"

# monitor progress of hpa, nodes, deployments, pods & svc in one screen.
## you'll see initial current metric percentage at somewhere between 250 - 305% higher than the target 50%.
# watch -n .5 "kubectl top nodes && echo "" && kubectl top pods && echo "" && kubectl get hpa,deploy,po,svc -o wide"

