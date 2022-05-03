.ONESHELL:

## load common variables and anything environment specific that overrides
export ENV_GLOBAL_PATH 	 ?= $(CURDIR)/config/common/.env
export ENV_OVERRIDE_PATH ?= $(CURDIR)/config/${ENVIRONMENT}/.env

-include $(ENV_GLOBAL_PATH)
-include $(ENV_OVERRIDE_PATH)

## export all vars
export

####
## Configure Calm DSL and Docker Container
####

.PHONY: docker-build
docker-build: ## Build Calm DSL Util Image with necessary tools to develop and manage Cloud-Native Apps (e.g., kubectl, argocd, git, helm, helmfile, etc.)
	@docker rmi -f calm-dsl-utils:latest
	@docker rmi -f ntnx/calm-dsl:latest
	@docker build -t calm-dsl-utils .

.PHONY: docker-run
docker-run: ## Launch into Calm DSL development container. If image isn't available, build will auto-run
	[ -n "$$(docker image ls calm-dsl-utils -q)" ] || make docker-build
	# this will just exec you into the interactive container
	@docker run --rm -it \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v `pwd`:/dsl-workspace \
		-v `pwd`/.local/${ENVIRONMENT}:${CALM_DSL_LOCAL_DIR_LOCATION}/ \
		-w '/dsl-workspace' \
		calm-dsl-utils /bin/sh -c "make help && /bin/zsh"

.PHONY: init-dsl-config
init-dsl-config: print-vars ## Initialize calm dsl configuration with environment specific configs.  Assumes that it will be running withing Container.
	# validating that you're inside docker container.  If you were just put into container, you may need to re-run last command
	[ -f /.dockerenv ] || make docker-run ENVIRONMENT=${ENVIRONMENT};
	[ -d ${CALM_DSL_LOCAL_DIR_LOCATION} ] || mkdir -p ${CALM_DSL_LOCAL_DIR_LOCATION} && cp -rf .local/${ENVIRONMENT}/* ${CALM_DSL_LOCAL_DIR_LOCATION}
	@touch ${CALM_DSL_LOCAL_DIR_LOCATION}/config.ini ${CALM_DSL_LOCAL_DIR_LOCATION}/dsl.db
	@calm init dsl --project "${CALM_PROJECT}";

## Common BP command based on DSL_BP path passed in. To Run, make create-dsl-bps <dsl_bp_folder_name>

create-dsl-bps launch-dsl-bps delete-dsl-bps delete-dsl-apps: init-dsl-config

create-dsl-bps: ### Create bp with corresponding git feature branch and short sha code. i.e., make create-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/blueprints/${DSL_BP} create-bp

launch-dsl-bps: ### Launch Blueprint that matches your git feature branch and short sha code. i.e., make launch-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/blueprints/${DSL_BP} launch-bp

delete-dsl-bps: ### Delete Blueprint that matches your git feature branch and short sha code. i.e., make delete-dsl-bps DSL_BP=karbon_admin_ws
	@make -C dsl/blueprints/${DSL_BP} delete-bp


## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

publish-new-dsl-bps publish-existing-dsl-bps unpublish-dsl-bps: init-dsl-config

publish-new-dsl-bps: ### First Time Publish of Standard DSL BP. i.e., make publish-new-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for new
	@make -C dsl/blueprints/${DSL_BP} publish-new-bp

publish-existing-dsl-bps: ### Publish Standard DSL BP of already existing. i.e., make publish-existing-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for existing
	@make -C dsl/blueprints/${DSL_BP} publish-existing-bp

unpublish-dsl-bps: ### UnPublish Standard DSL BP of already existing. i.e., make unpublish-dsl-bps DSL_BP=karbon_admin_ws
	# promote stable release to marketplace for existing
	@make -k -C dsl/blueprints/${DSL_BP} unpublish-bp

## Helm charts specific commands

create-helm-bps launch-helm-bps delete-helm-bps delete-helm-apps publish-new-helm-bps publish-existing-helm-bps unpublish-helm-bps: init-dsl-config

create-helm-bps: ### Create single helm chart bp (with current git branch / tag latest in name). i.e., make create-helm-bps CHART=argocd
	@make -C dsl/blueprints/helm_charts/${CHART} create-bp

launch-helm-bps: ### Launch single helm chart app (with current git branch / tag latest in name). i.e., make launch-helm-bps CHART=argocd
	@make -C dsl/blueprints/helm_charts/${CHART} launch-bp

delete-helm-bps: ### Delete single helm chart blueprint (with current git branch / tag latest in name). i.e., make delete-helm-bps CHART=argocd
	@make -C dsl/blueprints/helm_charts/${CHART} delete-bp

delete-helm-apps: ### Delete single helm chart app (with current git branch / tag latest in name). i.e., make delete-helm-apps CHART=argocd
	@make -C dsl/blueprints/helm_charts/${CHART} delete-app

create-all-helm-charts: ### Create all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
	ls dsl/blueprints/helm_charts | xargs -I {} make create-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

launch-all-helm-charts: ### Launch all helm chart blueprints with default test parameters (with current git branch / tag latest in name)
	ls dsl/blueprints/helm_charts | grep -v -E "kyverno|metallb|ingress-nginx|cert-manager" | xargs -I {} make launch-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

delete-all-helm-charts-apps: ### Delete all helm chart apps (with current git branch / tag latest in name)
	# remove pre-reqs last
	ls dsl/blueprints/helm_charts | grep -v -E "kyverno|metallb|ingress-nginx|cert-manager" | xargs -I {} make delete-helm-apps ENVIRONMENT=${ENVIRONMENT} CHART={}
	make delete-helm-apps CHART=ingress-nginx ENVIRONMENT=${ENVIRONMENT}
	make delete-helm-apps CHART=cert-manager ENVIRONMENT=${ENVIRONMENT}
	make delete-helm-apps CHART=metallb ENVIRONMENT=${ENVIRONMENT}

delete-all-helm-charts-bps: ### Delete all helm chart blueprints (with current git branch / tag latest in name)
	ls dsl/blueprints/helm_charts | xargs -I {} make delete-helm-bps CHART={} ENVIRONMENT=${ENVIRONMENT}

## Endpoint specific commands

create-dsl-endpoint create-all-dsl-endpoints: init-dsl-config

create-dsl-endpoint: ### Create Endpoint Resource. i.e., make create-dsl-endpoint EP=karbon_admin_ws
	calm create endpoint -f ./dsl/endpoints/${EP}/endpoint.py --name ${EP} -fc 

create-all-dsl-endpoints: ### Create ALL Endpoint Resources. i.e., make create-all-dsl-endpoints
	ls dsl/endpoints | xargs -I {} make create-dsl-endpoint EP={} ENVIRONMENT=${ENVIRONMENT}

## Runbook specific commands

create-dsl-runbook create-all-dsl-runbooks run-dsl-runbook run-all-dsl-runbook-scenarios: init-dsl-config

create-dsl-runbook: ### Create Runbook. i.e., make create-dsl-runbook RUNBOOK=manage_ad_dns
	calm create runbook -f ./dsl/runbooks/${RUNBOOK}/runbook.py --name ${RUNBOOK} -fc 

create-all-dsl-runbooks: ### Create ALL Endpoint Resources. i.e., make create-all-dsl-runbooks
	ls dsl/runbooks | xargs -I {} make create-dsl-runbook RUNBOOK={} ENVIRONMENT=${ENVIRONMENT}

run-dsl-runbook: ### Run Runbook with Specific Scenario. i.e., make run-dsl-runbook RUNBOOK=manage_ad_dns SCENARIO=create_ingress_dns_params
	calm run runbook -i --input-file ./dsl/runbooks/${RUNBOOK}/init-scenarios/${SCENARIO}.py ${RUNBOOK}

run-all-dsl-runbook-scenarios: ### Runs all dsl runbook scenarios for given runbook i.e., make run-all-dsl-runbook-scenarios RUNBOOK=manage_ad_dns
	@ls dsl/runbooks/${RUNBOOK}/init-scenarios/*.py | cut -d/ -f5 | cut -d. -f1 | xargs -I {} make run-dsl-runbook RUNBOOK=${RUNBOOK} SCENARIO={}


## WORKFLOWS

init-karbon-admin-ws init-kalm-cluster: init-dsl-config

init-karbon-admin-ws: ### Initialize Karbon Admin Bastion Workstation and Endpoint. .i.e., make init-karbon-admin-ws ENVIRONMENT=kalm-main-16-1
	@make create-dsl-bps launch-dsl-bps DSL_BP=karbon_admin_ws ENVIRONMENT=${ENVIRONMENT}
	@calm get apps -n karbon-admin-ws -q -l 1 | xargs -I {} calm describe app {} -o json | jq '.status.resources.deployment_list[0].substrate_configuration.element_list[0].address' | tr -d '"' > ${CALM_DSL_LOCAL_DIR_LOCATION}/karbon_admin_ws_ip
	@make create-all-dsl-endpoints create-all-dsl-runbooks ENVIRONMENT=${ENVIRONMENT}
	# @make run-all-dsl-runbook-scenarios RUNBOOK=manage_ad_dns ENVIRONMENT=${ENVIRONMENT}
	@make create-all-helm-charts publish-all-new-helm-bps ENVIRONMENT=${ENVIRONMENT}

init-kalm-cluster: ### Initialize Karbon Cluster. i.e., make init-kalm-cluster ENVIRONMENT=kalm-main-16-1
	# @make run-dsl-runbook RUNBOOK=manage_ad_dns SCENARIO=create_objects_bucket_dns_params ENVIRONMENT=${ENVIRONMENT}
	# @make run-dsl-runbook RUNBOOK=manage_ad_dns SCENARIO=create_wildcard_ingress_dns_params ENVIRONMENT=${ENVIRONMENT}
	# @make run-dsl-runbook RUNBOOK=manage_ad_dns SCENARIO=create_wildcard_simple_ingress_dns_params ENVIRONMENT=${ENVIRONMENT}
	@make create-dsl-bps launch-dsl-bps DSL_BP=karbon_cluster_deployment ENVIRONMENT=${ENVIRONMENT}

bootstrap-kalm-all: ### Bootstrap All
	@make init-karbon-admin-ws init-kalm-cluster ENVIRONMENT=${ENVIRONMENT}

## RELEASE MANAGEMENT

## Following should be run from master branch along with git tag v1.0.x-$(git rev-parse --short HEAD), git push origin --tags, validate with git tag -l

# If needing to publish from a previous commit/tag than current master HEAD, from master, run git reset --hard tagname to set local working copy to that point in time.
# Run git reset --hard origin/master to return your local working copy back to latest master HEAD.

publish-new-helm-bps: ### First Time Publish of Single Helm Chart. i.e., make publish-new-helm-bps CHART=argocd
	# promote stable release to marketplace for new
	@make -C dsl/blueprints/helm_charts/${CHART} publish-new-bp

publish-existing-helm-bps: ### Publish Single Helm Chart of already existing Helm Chart. i.e., make publish-existing-helm-bps CHART=argocd
	# promote stable release to marketplace for existing
	@make -C dsl/blueprints/helm_charts/${CHART} publish-existing-bp

unpublish-helm-bps: ### Unpublish Single Helm Chart Blueprint - latest git release. i.e., make unpublish-helm-bps CHART=argocd
	# unpublish stable release to marketplace for existing
	@make -k -C dsl/blueprints/helm_charts/${CHART} unpublish-bp

publish-all-new-helm-bps: ### First Time Publish of ALL Helm Chart Blueprints into Marketplace
	@ls dsl/blueprints/helm_charts | xargs -I {} make publish-new-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

publish-all-existing-helm-bps: ### Publish New Version of all existing helm chart marketplace items with latest git release.
	@ls dsl/blueprints/helm_charts | xargs -I {} make publish-existing-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

unpublish-all-helm-bps: ### Unpublish all Helm Chart Blueprints of latest git release (i.e., git tag --list)
	@ls dsl/blueprints/helm_charts | xargs -I {} make unpublish-helm-bps ENVIRONMENT=${ENVIRONMENT} CHART={}

##############
## Helpers

.PHONY: print-vars
print-vars: ### Print environment variables. i.e., make print-vars ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | egrep -vi "pass" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.PHONY: print-secrets
print-secrets: ### Print variables including secrets. i.e., make print-secrets ENVIRONMENT={environment_folder_name}
	@for envvar in $$(cat $(ENV_GLOBAL_PATH) $(ENV_OVERRIDE_PATH) | cut -d= -f1 | sort -usf | xargs -n 1); do `echo env` | egrep "USER|PASS|KEY|SECRET" | grep "$$envvar=" 2>/dev/null; done; 2>/dev/null

.DEFAULT_GOAL := help
.PHONY: help
help: ### Show this help
	@egrep -h '\s###\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?### "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

####
## Configure Local KUBECTL config and ssh keys for Karbon
####

.PHONY: download-karbon-creds
download-karbon-creds: ### Leverage karbon krew/kubectl plugin to login and download config and ssh keys
	@kubectl-karbon login -k --server ${PC_IP_ADDRESS} --cluster ${KARBON_CLUSTER} --user admin --kubeconfig ~/.kube/${KARBON_CLUSTER}.cfg --force
	make merge-kubectl-contexts

.PHONY: merge-kubectl-contexts
merge-kubectl-contexts: ### Merge all K8s cluster kubeconfigs within path to config file.  Needed to support multiple clusters in future
	@export KUBECONFIG=$$KUBECONFIG:~/.kube/${KARBON_CLUSTER}.cfg; \
		kubectl config view --flatten >| ~/.kube/config && chmod 600 ~/.kube/config;
	@kubectl config use-context ${KUBECTL_CONTEXT};
	@kubectl cluster-info

.PHONY: fix-image-pull-secrets
fix-image-pull-secrets: ### Add image pull secret to get around image download rate limiting issues
	@kubectl get ns -o name | cut -d / -f2 | xargs -I {} sh -c "kubectl create secret docker-registry image-pull-secret --docker-username=${DOCKER_HUB_USER} --docker-password=${DOCKER_HUB_PASS} -n {} --dry-run=client -o yaml | kubectl apply -f - "
	kubectl get serviceaccount --no-headers --all-namespaces | awk '{ print $$1 , $$2 }' | xargs -n2 sh -c 'kubectl patch serviceaccount $$2 -p "{\"imagePullSecrets\": [{\"name\": \"image-pull-secret\"}]}" -n $$1' sh
