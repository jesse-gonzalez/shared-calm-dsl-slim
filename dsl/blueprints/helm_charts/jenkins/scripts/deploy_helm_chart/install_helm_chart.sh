WILDCARD_INGRESS_DNS_FQDN=@@{wildcard_ingress_dns_fqdn}@@
NIPIO_INGRESS_DOMAIN=@@{nipio_ingress_domain}@@
NAMESPACE=@@{namespace}@@
INSTANCE_NAME=@@{instance_name}@@
K8S_CLUSTER_NAME=@@{k8s_cluster_name}@@

export KUBECONFIG=~/${K8S_CLUSTER_NAME}_${INSTANCE_NAME}.cfg

if ! kubectl get namespaces -o json | jq -r ".items[].metadata.name" | grep @@{namespace}@@
then
  echo "Creating namespace ${NAMESPACE}"
  kubectl create namespace ${NAMESPACE}
fi

## making sure docker secret is there to pull down image from private repo.  Jenkins lts image already has plugins installed
DOCKER_HUB_USER=@@{Docker Hub User.username}@@
DOCKER_HUB_PASS=@@{Docker Hub User.secret}@@

kubectl create secret docker-registry image-pull-secret --docker-username=${DOCKER_HUB_USER} --docker-password=${DOCKER_HUB_PASS} -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f - 

## configure jenkins configuration as code plugin yaml
GITHUB_USER=@@{GitHub User.username}@@
GITHUB_PASS=@@{GitHub User.secret}@@

## configure admin user
JENKINS_USER=@@{Jenkins User.username}@@
JENKINS_PASS=@@{Jenkins User.secret}@@

cat <<EOF | tee jenkins-jcasc-config-values.yaml
controller:
  JCasC:
    configScripts:
      jenkins-casc-configs: |
        credentials:
          system:
            domainCredentials:
            - credentials:
                - usernamePassword:
                    id: github-creds
                    password: $(echo $GITHUB_PASS)
                    scope: GLOBAL
                    username: $(echo $GITHUB_USER)
                    usernameSecret: true
                    description: "Github credentials for nutanix repos"
        jenkins:
          systemMessage: "Jenkins configured automatically by Nutanix Calm and Jenkins Configuration as Code plugin\n\n"
        jobs:
        - script: >
            multibranchPipelineJob('simple-rsvp-app-multibranch-pipeline') {
              branchSources {
                github {
                  // The id option in the Git and GitHub branch source contexts is now mandatory (JENKINS-43693).
                  id('12312313') // IMPORTANT: use a constant and unique identifier
                  scanCredentialsId('github-creds')
                  repoOwner('jesse-gonzalez')
                  repository('simple-rsvp-app')
                }
              }
              orphanedItemStrategy {
                discardOldItems {
                  numToKeep(5)
                }
              }
              triggers {
                periodic(1)
              }
            }
EOF

# this step will configure jenkins with ingress tls enabled and self-signed certs managed by cert-manager
helm repo add jenkinsci https://charts.jenkins.io
helm repo update
helm upgrade --install ${INSTANCE_NAME} jenkinsci/jenkins \
  --namespace ${NAMESPACE} \
  --set controller.ingress.enabled=true \
  --set-string controller.ingress.annotations."kubernetes\.io\/ingress\.class"=nginx \
  --set-string controller.ingress.annotations."cert-manager\.io\/cluster-issuer"=selfsigned-cluster-issuer \
  --set-string controller.ingress.annotations."nginx\.ingress\.kubernetes\.io\/force-ssl-redirect"=false \
  --set-string controller.ingress.annotations."nginx\.ingress\.kubernetes\.io\/add-base-url"=true \
  --set controller.ingress.hostName="${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN}" \
  --set controller.ingress.tls[0].hosts[0]=${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} \
  --set controller.ingress.tls[0].secretName=${INSTANCE_NAME}-npio-tls \
  --set controller.initializeOnce=true \
  --set controller.installPlugins=false \
  --set controller.installLatestPlugins=false \
  --set controller.imagePullSecretName=image-pull-secret \
  --set controller.image=ntnxdemo/jenkins \
  --set controller.tag=v0.1.1 \
  --set controller.cloudName=${K8S_CLUSTER_NAME} \
  --set controller.adminUser="${JENKINS_USER}" \
  --set controller.adminPassword="${JENKINS_PASS}" \
  --set rbac.create=true \
  --set persistence.create=true \
  --set persistence.size=20Gi \
  --values jenkins-jcasc-config-values.yaml \
  --wait \
  --wait-for-jobs \
  --timeout 10m0s

kubectl wait --for=condition=Ready pod -l app.kubernetes.io/part-of=jenkins -n ${NAMESPACE}

helm status ${INSTANCE_NAME} -n ${NAMESPACE}

echo "Navigate to https://${INSTANCE_NAME}.${NIPIO_INGRESS_DOMAIN} via browser to access instance

After reaching the UI the first time you can login with username: admin and the password will be the
name of the server pod. You can get the pod name by running:

kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo"

TEMP_ADMIN_PASS=$(kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/chart-admin-password && echo)

echo "username: admin, password: ${TEMP_ADMIN_PASS}"


# jenkins-plugin-cli --plugins blueocean:1.25.3

## https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/VALUES_SUMMARY.md#backup
## --set backup.enabled=true \
## backup.existingSecret.*.awsaccesskey
## backup.existingSecret.*.awssecretkey  
## backup.destination  s3://jenkins-data/backup
## controller.admin.passwordKey

