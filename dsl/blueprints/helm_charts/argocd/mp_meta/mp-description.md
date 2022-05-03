*Argo Continuous Delivery Helm Chart*

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

### Chart Details

This chart will do the following:

- Deploy ArgoCD
- Exposes ArgoCD with Ingress-Nginx

#### Prerequisites:

- Existing Karbon Cluster

The following services have been pre-configured:

- `MetalLB` - [more info](https://metallb.universe.tf/)
- `Cert-Manager` - [more info](https://cert-manager.io/docs/installation/kubernetes/)
- `Ingress-Nginx` - [more info](https://kubernetes.github.io/ingress-nginx/)
