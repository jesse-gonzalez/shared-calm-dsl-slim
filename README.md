# shared-calm-dsl-slim
Public Repo for sharing DSL blueprints used in Calm Demos

- update .local secrets

- generate gpg key

## Pre-Requisites

- Make
- Docker
- Helm
- Helm Secrets Plugin
- Sops
- Kubectl
- jq
- yq

## Make Build Targets

```bash
❯ make help                                                                                                                                                                                  ─╯
bootstrap-kalm-all   Bootstrap All
create-all-dsl-endpoints Create ALL Endpoint Resources. i.e., make create-all-dsl-endpoints
create-all-dsl-runbooks Create ALL Endpoint Resources. i.e., make create-all-dsl-runbooks
create-all-helm-charts Create all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
create-dsl-bps       Create bp with corresponding git feature branch and short sha code. i.e., make create-dsl-bps DSL_BP=karbon_admin_ws
create-dsl-endpoint  Create Endpoint Resource. i.e., make create-dsl-endpoint EP=karbon_admin_ws
create-dsl-runbook   Create Runbook. i.e., make create-dsl-runbook RUNBOOK=manage_ad_dns
create-helm-bps      Create single helm chart bp (with current git branch / tag latest in name). i.e., make create-helm-bps CHART=argocd
delete-all-helm-charts-apps Delete all helm chart apps (with current git branch / tag latest in name)
delete-all-helm-charts-bps Delete all helm chart blueprints (with current git branch / tag latest in name)
delete-dsl-apps      Delete Application that matches your git feature branch and short sha code. i.e., make delete-dsl-apps DSL_BP=karbon_admin_ws
delete-dsl-bps       Delete Blueprint that matches your git feature branch and short sha code. i.e., make delete-dsl-bps DSL_BP=karbon_admin_ws
delete-helm-apps     Delete single helm chart app (with current git branch / tag latest in name). i.e., make delete-helm-apps CHART=argocd
delete-helm-bps      Delete single helm chart blueprint (with current git branch / tag latest in name). i.e., make delete-helm-bps CHART=argocd
download-karbon-creds Leverage karbon krew/kubectl plugin to login and download config and ssh keys
fix-image-pull-secrets Add image pull secret to get around image download rate limiting issues
help                 Show this help
init-kalm-cluster    Initialize Karbon Cluster. i.e., make init-kalm-cluster ENVIRONMENT=kalm-main-16-1
init-karbon-admin-ws Initialize Karbon Admin Bastion Workstation and Endpoint. .i.e., make init-karbon-admin-ws ENVIRONMENT=kalm-main-16-1
launch-all-helm-charts Launch all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
launch-dsl-bps       Launch Blueprint that matches your git feature branch and short sha code. i.e., make launch-dsl-bps DSL_BP=karbon_admin_ws
launch-helm-bps      Launch single helm chart app (with current git branch / tag latest in name). i.e., make launch-helm-bps CHART=argocd
merge-kubectl-contexts Merge all K8s cluster kubeconfigs within path to config file.  Needed to support multiple clusters in future
print-secrets        Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name}
print-vars           Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
publish-all-existing-helm-bps Publish New Version of all existing helm chart marketplace items with latest git release.
publish-all-new-helm-bps First Time Publish of ALL Helm Chart Blueprints into Marketplace
publish-existing-dsl-bps Publish Standard DSL BP of already existing. i.e., make publish-existing-dsl-bps DSL_BP=karbon_admin_ws
publish-existing-helm-bps Publish Single Helm Chart of already existing Helm Chart. i.e., make publish-existing-helm-bps CHART=argocd
publish-new-dsl-bps  First Time Publish of Standard DSL BP. i.e., make publish-new-dsl-bps DSL_BP=karbon_admin_ws
publish-new-helm-bps First Time Publish of Single Helm Chart. i.e., make publish-new-helm-bps CHART=argocd
run-all-dsl-runbook-scenarios Runs all dsl runbook scenarios for given runbook i.e., make run-all-dsl-runbook-scenarios RUNBOOK=manage_ad_dns
run-dsl-runbook      Run Runbook with Specific Scenario. i.e., make run-dsl-runbook RUNBOOK=manage_ad_dns SCENARIO=create_ingress_dns_params
unpublish-all-helm-bps Unpublish all Helm Chart Blueprints of latest git release (i.e., git tag --list)
unpublish-dsl-bps    UnPublish Standard DSL BP of already existing. i.e., make unpublish-dsl-bps DSL_BP=karbon_admin_ws
unpublish-helm-bps   Unpublish Single Helm Chart Blueprint - latest git release. i.e., make unpublish-helm-bps CHART=argocd

```


## Build and Run Docker Container

`make docker-build && make docker-run`



## Configure New Environment

### Install the helm secrets plug-in

Before using the helm secrets plug-in, first ensure that the plug-in is installed in the local helm. Installing the helm plug-in is very simple. You can directly install it with the following command

helm plugin install https://github.com/futuresimple/helm-secrets

```
$ helm plugin list
NAME    VERSION DESCRIPTION                                                                  
secrets 3.11.0  This plugin provides secrets values encryption for Helm charts secure storing
```

Helm secrets plugin is dependent on `sops`

### Generate GPG key pair

Example GPG key for Helm Secrets

```bash
gpg --batch --generate-key <<EOF
%echo Generating a basic OpenPGP key for HELM Secret
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: HELM Secret
Name-Comment: Used for HELM Secret Plugin
Name-Email: helm-secret@email.com
Expire-Date: 0
%no-ask-passphrase
%no-protection
%commit
%echo done
EOF
```

Export GPG and store in `.local/common` directory


### Create Environment Dir and Generate Secrets

1. Copy `config/templates` dir to `config/<environment>` dir

>`cp -rf config/templates config/ntnx-lab-demo`

2. Get the GPG Key needed for `.sops.yaml` file

> `gpg --list-key helm-secret@email.com`

OR

> `gpg --list-key helm-secret@email.com | head -n 2 | tail -n 1 | tr -d " "`

3. Update `config/<environment>/.sops.yaml` with generated gpg key

```bash
creation_rules:
    - pgp: '<PGP_KEY>'
```

4. Update `config/<environment>/secrets.yaml` with correct creds

```bash
jenkins_user: admin
jenkins_password: <password>
argocd_user: admin
argocd_password: <password>
calm_dsl_user: admin
calm_dsl_pass: <password>
nutanix_key_user: nutanix
nutanix_user: nutanix
nutanix_password: <password>
prism_central_user: admin
prism_central_password: <password>
prism_element_user: admin
prism_element_password: <password>
windows_domain_user: admin@domain.local
windows_domain_password: <password>
docker_hub_user: docker-user
docker_hub_password: <password>
```

5. Encrypt `config/<environment>/secrets.yaml` using helm secrets plugin

> `helm secrets enc config/rancher-dev/secrets.yaml`

6. Update `config/<environment>/.env` with properties that need to be overridden
