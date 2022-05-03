*Jenkins Continuous Delivery Helm Chart*

Jenkins is a continuous integration / delivery solution leveraged for building container images.

### Chart Details

This chart will do the following:

- Deploy Jenkins
- Exposes Jenkins with Ingress-Nginx

#### Prerequisites

- Existing Karbon Cluster

The following services have been pre-configured:

- `MetalLB` - [more info](https://metallb.universe.tf/)
- `Cert-Manager` - [more info](https://cert-manager.io/docs/installation/kubernetes/)
- `Ingress-Nginx` - [more info](https://kubernetes.github.io/ingress-nginx/)
