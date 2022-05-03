NAMESPACE=default
SERVICE_ACCOUNT_NAME=kalm-sa
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

##  Create Calm service account in K8s
kubectl create serviceaccount ${SERVICE_ACCOUNT_NAME} --namespace ${NAMESPACE}

##  Bind Calm service account with cluster-admin role
kubectl create clusterrolebinding ${SERVICE_ACCOUNT_NAME}-rb --clusterrole=cluster-admin --serviceaccount=${NAMESPACE}:${SERVICE_ACCOUNT_NAME} --namespace=${NAMESPACE}

##  Get the service account secret name
SA_SECRET_NAME=$(kubectl get serviceaccounts ${SERVICE_ACCOUNT_NAME} -o jsonpath='{.secrets[].name}' -n ${NAMESPACE});

##  Get the service account token
SA_TOKEN=$(kubectl get secrets ${SA_SECRET_NAME} -o jsonpath='{.data.token}' -n ${NAMESPACE} | base64 -d);

##  Get the CA certificate - if needed
CA_CERT=$(kubectl config view --minify --raw -o jsonpath='{.clusters[*].cluster.certificate-authority-data}' | base64 --decode);

##  Set credentials in local kubeconfig file
kubectl config set-credentials ${SERVICE_ACCOUNT_NAME} --token=${SA_TOKEN}

##  Set context in local kubeconfig file
kubectl config set-context ${SERVICE_ACCOUNT_NAME}@${K8S_CLUSTER_NAME} --cluster=${K8S_CLUSTER_NAME} --user=${SERVICE_ACCOUNT_NAME} --namespace=${NAMESPACE}

##  Use context and set namespace to correct namespace
kubectl config use-context ${SERVICE_ACCOUNT_NAME}@${K8S_CLUSTER_NAME}
#kubectl config set-context --current --namespace=${NAMESPACE}

##  Create file on local .kube dir
#kubectl config view --minify --raw >| ~/.kube/${SERVICE_ACCOUNT_NAME}_$K8S_CLUSTER_NAME.cfg

##  Validate ServiceAccount has access
#kubectl get nodes -o wide
