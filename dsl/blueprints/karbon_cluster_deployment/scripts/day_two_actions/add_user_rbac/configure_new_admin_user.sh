#NAMESPACE=@@{namespace}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@
K8S_USER_NAME=@@{k8s_user_name}@@

#K8S_ROLE_NAME=@@{k8s_role_name}@@
# K8S_ROLE_TYPE=@@{k8s_role_type}@@
# K8S_ROLE_VERBS=@@{k8s_role_verbs}@@
# K8S_ROLE_RESOURCES=@@{k8s_role_resources}@@

K8S_CLUSTER_NAME=kalm-aks-demo
K8S_USER_NAME=kalm-admin

# future prompts
K8S_ROLE_NAME=${K8S_USER_NAME}-role
# K8S_ROLE_TYPE=clusterrole
# K8S_ROLE_VERBS=*
# K8S_ROLE_RESOURCES=*

# set current context to cluster we're actively working with.
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/$K8S_CLUSTER_NAME.cfg
kubectl config use-context $K8S_CLUSTER_NAME-context

# setting common file names for user / cluster instance
COMMON_FILE_NAME=${K8S_USER_NAME}_${K8S_CLUSTER_NAME}

# cleanup files if they already exist
[ -f $HOME/.ssh/${COMMON_FILE_NAME}.key ] || rm $HOME/.ssh/${COMMON_FILE_NAME}.key
[ -f $HOME/.ssh/${COMMON_FILE_NAME}.csr ] || rm $HOME/.ssh/${COMMON_FILE_NAME}.csr
[ -f $HOME/.ssh/${COMMON_FILE_NAME}.crt ] || rm $HOME/.ssh/${COMMON_FILE_NAME}.crt
[ -f $HOME/.ssh/${COMMON_FILE_NAME}-ca.crt ] || rm $HOME/.ssh/${COMMON_FILE_NAME}-ca.crt
[ -f $HOME/.kube/${COMMON_FILE_NAME}.cfg ] || rm $HOME/.ssh/${COMMON_FILE_NAME}.cfg

# check for existing clusterrolebindings
if kubectl get clusterrolebinding -o json | jq -r ".items[].metadata.name" | grep ${K8S_ROLE_NAME}-crb
then
  kubectl delete clusterrolebinding ${K8S_ROLE_NAME}-crb
fi

# check for existing clusterroles
if kubectl get clusterroles -o json | jq -r ".items[].metadata.name" | grep ${K8S_ROLE_NAME}
then
  kubectl delete clusterrole ${K8S_ROLE_NAME}
fi

# check for existing csrs
if kubectl get certificatesigningrequests -o json | jq -r ".items[].metadata.name" | grep ${K8S_USER_NAME}
then
  kubectl delete certificatesigningrequests ${K8S_USER_NAME}
fi

# Create a private key
openssl genrsa -out $HOME/.ssh/${COMMON_FILE_NAME}.key 2048

# Create CSR
# CN (Common Name) is your username, O (Organization) is the Group

openssl req -new -key $HOME/.ssh/${COMMON_FILE_NAME}.key -out $HOME/.ssh/${COMMON_FILE_NAME}.csr -subj "/CN=${K8S_USER_NAME}/O=${K8S_ROLE_NAME}"

## Verify CSR
openssl req -in $HOME/.ssh/${COMMON_FILE_NAME}.csr -noout -text -verify
cat $HOME/.ssh/${COMMON_FILE_NAME}.csr

# The CertificateSigningRequest needs to be base64 encoded and also have the header and trailer pulled out.

cat $HOME/.ssh/${COMMON_FILE_NAME}.csr | base64 | tr -d "\n" > $HOME/.ssh/${COMMON_FILE_NAME}.base64.csr

# Submit the CertificateSigningRequest to the API Server based on k8s version

cat <<EOF | kubectl apply -f -
  apiVersion: certificates.k8s.io/v1beta1
  kind: CertificateSigningRequest
  metadata:
    name: ${K8S_USER_NAME}
  spec:
    groups:
    - system:authenticated
    request: $(cat $HOME/.ssh/${COMMON_FILE_NAME}.base64.csr)
    usages:
    - client auth
EOF

# Let's get the CSR to see it's current state. The CSR will delete after an hour

kubectl get certificatesigningrequests

# Auto Approve CSR

kubectl certificate approve ${K8S_USER_NAME}

# Let's go ahead and save the certificate into a local file.

kubectl get certificatesigningrequests ${K8S_USER_NAME} \
  -o jsonpath='{ .status.certificate }'  | base64 --decode > $HOME/.ssh/${COMMON_FILE_NAME}.crt


# Read the certficate itself

openssl x509 -in $HOME/.ssh/${COMMON_FILE_NAME}.crt -text -noout | head -n 15

# Creating a kubeconfig file for a new read only user

kubectl config view --raw -o json | jq -r '.clusters[0].cluster."certificate-authority-data"' | tr -d '"' | base64 --decode > $HOME/.ssh/${COMMON_FILE_NAME}-ca.crt

# create clusterrole and clusterrole binding

kubectl create clusterrole ${K8S_ROLE_NAME} --verb=* --resource=*
kubectl create clusterrolebinding ${K8S_ROLE_NAME}-crb \
  --clusterrole=admin --user=${K8S_USER_NAME}

# Create the cluster entry
K8S_CLUSTER_API_ENDPOINT=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

kubectl config set-cluster ${K8S_CLUSTER_NAME} \
  --server=${K8S_CLUSTER_API_ENDPOINT} \
  --certificate-authority=$HOME/.ssh/${COMMON_FILE_NAME}-ca.crt \
  --embed-certs=true \
  --kubeconfig=$HOME/.kube/${COMMON_FILE_NAME}.cfg

kubectl config get-clusters

# Add user to new kubeconfig file ${COMMON_FILE_NAME}.cfg

kubectl config set-credentials ${K8S_USER_NAME} \
  --client-key=$HOME/.ssh/${COMMON_FILE_NAME}.key \
  --client-certificate=$HOME/.ssh/${COMMON_FILE_NAME}.crt \
  --embed-certs=true \
  --kubeconfig=$HOME/.kube/${COMMON_FILE_NAME}.cfg

# Add the context, context name, cluster name, user name

kubectl config set-context ${K8S_USER_NAME}@${K8S_CLUSTER_NAME} \
  --cluster=${K8S_CLUSTER_NAME} \
  --user=${K8S_USER_NAME} \
  --kubeconfig=$HOME/.kube/${COMMON_FILE_NAME}.cfg

# Validate that there's a cluster, a user, and a context defined

kubectl config view --kubeconfig=$HOME/.kube/${COMMON_FILE_NAME}.cfg

# switch kubectl config context

kubectl config use-context ${K8S_USER_NAME}@${K8S_CLUSTER_NAME} --kubeconfig=$HOME/.kube/${COMMON_FILE_NAME}.conf

# Validate all is fine
export KUBECONFIG=$KUBECONFIG:$KUBECONFIG_HOME/${COMMON_FILE_NAME}.cfg
kubectl get pods -v 6
#unset KUBECONFIG
