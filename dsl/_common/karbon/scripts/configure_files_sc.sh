
echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

echo "Configuring Nutanix Files Static Provisioner Storage Class"

# PRE-REQ: NFS Multi-Protocol needs to be configured on Files.  
# Also, Export should be set to Auth: System, Default Acccess: None, Client w/ RWX access Subnet and Anonymous GID/UID: 1024 and All Squash
# NUTANIX_FILES_NFS_FQDN=BootcampFS.ntnxlab.local
# NUTANIX_FILES_NFS_EXPORT=/kalm-main-nfs

NUTANIX_FILES_NFS_FQDN=@@{nutanix_files_nfs_fqdn}@@
NUTANIX_FILES_NFS_EXPORT=@@{nutanix_files_nfs_export}@@

cat <<EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
    name: static-nfs-sc
    annotations:
        storageclass.kubernetes.io/is-default-class: "false"
provisioner: csi.nutanix.com
parameters:
    nfsServer: $(echo $NUTANIX_FILES_NFS_FQDN)
    nfsPath: $(echo $NUTANIX_FILES_NFS_EXPORT)
    storageType: NutanixFiles
EOF

# validate storage class
kubectl describe sc static-nfs-sc

# get dynamically generated secret name from karbon in kube-system - ntnx-secret-0005dbd4-aca9-63af-2592-0cc47ac54632.
#DYN_NTNX_SECRET=$(kubectl get secrets -n kube-system -o name | grep ntnx-secret | cut -d/ -f2)

# PRISM_ELEMENT_IP=@@{pc_instance_ip}@@
# PRISM_ELEMENT_PORT=@@{pc_instance_port}@@
# PRISM_ELEMENT_USER=@@{Prism Central User.username}@@
# PRISM_ELEMENT_PASS=@@{Prism Central User.secret}@@

# PRISM_ELEMENT_IP=10.38.16.7
# PRISM_ELEMENT_PORT=9440
# PRISM_ELEMENT_USER=admin
# PRISM_ELEMENT_PASS=ntnxSAS/4u!

# base64 encoded prism-ip:prism-port:admin:password. E.g.: echo -n "10.0.00.000:9440:admin:mypassword" | base64
# NTNX_SECRET_B64=$( echo -n "${PRISM_ELEMENT_IP}:${PRISM_ELEMENT_PORT}:${PRISM_ELEMENT_USER}:${PRISM_ELEMENT_PASS}" | base64 )

# # 
# cat <<EOF | kubectl apply -f -
# apiVersion: v1
# kind: Secret
# metadata:
#  name: ntnx-secret
#  namespace: kube-system
# data:
#  key: $(echo $NTNX_SECRET_B64)
# EOF

# # create storage class
# cat <<EOF | kubectl apply -f -
# kind: StorageClass
# apiVersion: storage.k8s.io/v1
# metadata:
#     name: dynamic-nfs-sc
# provisioner: csi.nutanix.com
# parameters:
#     csi.storage.k8s.io/node-publish-secret-name: ntnx-secret
#     csi.storage.k8s.io/node-publish-secret-namespace: kube-system
#     csi.storage.k8s.io/controller-expand-secret-name: ntnx-secret
#     csi.storage.k8s.io/controller-expand-secret-namespace: kube-system
#     dynamicProv: ENABLED
#     nfsServerName: $(echo $NUTANIX_FILES_NFS_FQDN)
#     csi.storage.k8s.io/provisioner-secret-name: ntnx-secret
#     csi.storage.k8s.io/provisioner-secret-namespace: kube-system
#     storageType: NutanixFiles
# allowVolumeExpansion: true
# EOF


# validate storage class
# kubectl describe sc dynamic-nfs-sc