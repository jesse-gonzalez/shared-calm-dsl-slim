*Nutanix Karbon* is a curated turnkey offering that provides simplified provisioning and operations of Kubernetes clusters.
*Kubernetes* (aka. k8s) is an open source container orchestration system for deploying and managing container-based applications.

#### Prerequisites:

- Minimum Karbon Versions: `2.1+`
- Nutanix AHV Managed Network with IPAM Enabled

#### Hardware Requirement:

For `Development topology`, minimum required are total 3 nodes:

- 1 Master node - 2 vCPU, 4 GiB RAM, 120 GiB Disk
- 1 Etcd node - 4 vCPU, 8 GiB RAM, 40 GiB Disk
- 1 Worker node * - each with 8 vCPU, 8 GiB RAM, 120 GiB Disk

For `Production Multi-Master Active/Passive topology`, minimum required are total 6 nodes:

- 2 Master nodes - each with 4 vCPU, 4 GiB RAM, 120 GiB Disk
- 3 Etcd nodes - each with 4 vCPU, 8 GiB RAM, 40 GiB Disk
- 1 Worker nodes * - each with 8 vCPU, 8 GiB RAM, 120 GiB Disk
- 1 Static IP Address - for Master API Server VIP

*customizable at launch

#### Flavors:

- Deployment Topologies:
  - `Development`
  - `Production Multi-Master Active/Passive`

- Container Network Interface (CNI) plugins:
  - `Flannel` (Default)
  - `Calico`

#### Resources Installed:

The following resources are installed by default:

- `Kubernetes Dashboard` - [more info](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- `MetalLB` - [more info](https://metallb.universe.tf/)
- `Cert-Manager` - [more info](https://cert-manager.io/docs/installation/kubernetes/)
- `Ingress-Nginx` - [more info](https://kubernetes.github.io/ingress-nginx/)

#### Lifecycle:

- Scale In/Out Kubernetes Worker Nodes
- Upgrade Kubernetes Cluster
- Add/Remove Private Registry
