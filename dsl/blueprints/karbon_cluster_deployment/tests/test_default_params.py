import os

variable_list = [
    { "value": { "value": os.getenv("DOMAIN_NAME") }, "context": "Default", "name": "domain_name" },
    { "value": { "value": os.getenv("DNS") }, "context": "Default", "name": "dns_server" },
    { "value": { "value": os.getenv("NUTANIX_FILES_NFS_FQDN") }, "context": "Default", "name": "nutanix_files_nfs_fqdn" },
    { "value": { "value": os.getenv("NUTANIX_FILES_NFS_EXPORT") }, "context": "Default", "name": "nutanix_files_nfs_export" },
    { "value": { "value": os.getenv("PC_PORT") }, "context": "Default", "name": "pc_instance_port" },
    { "value": { "value": os.getenv("PC_IP_ADDRESS") }, "context": "Default", "name": "pc_instance_ip" },
    { "value": { "value": os.getenv("KARBON_WORKER_COUNT") }, "context": "Default", "name": "worker_count" },
    # Alternatives if prod - default-karbon-prod-container
    { "value": { "value": os.getenv("KARBON_STORAGE_CONTAINER") }, "context": "Default", "name": "storage_container_name" },
    # Alternatives if vLAN_110 = "10.59.110.50-10.59.110.54", if vLAN_115 "10.59.115.50-10.59.115.54"
    { "value": { "value": os.getenv("KARBON_LB_ADDRESSPOOL") }, "context": "Default", "name": "metallb_network_range" },
    # Alternatives vLAN_110, vLAN_115
    { "value": { "value": os.getenv("KARBON_VLAN") }, "context": "Default", "name": "network" },
    { "value": { "value": os.getenv("KARBON_CONTAINER_OS_VER") }, "context": "Default", "name": "node_os_version" },
    { "value": { "value": os.getenv("KARBON_K8S_VER") }, "context": "Default", "name": "k8s_version" },
    { "value": { "value": os.getenv("PE_CLUSTER_NAME") }, "context": "Default", "name": "nutanix_ahv_cluster" },
    { "value": { "value": "default" }, "context": "Default", "name": "namespace" },
    { "value": { "value": os.getenv("KARBON_CLUSTER") }, "context": "Default", "name": "k8s_cluster_name"},
    # Alternatives Calico, Flannel
    { "value": { "value": os.getenv("KARBON_CNI_NAME") }, "context": "Default", "name": "cni_name" },
    # Alternatives - if VLAN 110 - 10.59.110.55, if VLAN 115 10.59.110.56.  If Development, just leave a space, to ensure regex doesn't fail
    { "value": { "value": os.getenv("KARBON_EXT_IPV4") }, "context": "Default", "name": "external_ipv4_addr" },
    # Alternatives - Development or Production - Multi-Master Active/Passive
    { "value": { "value": os.getenv("KARBON_CLUSTER_TYPE") }, "context": "Default", "name": "cluster_type" },
    { "value": { "value": "false" }, "context": "Default", "name": "autoscaler_enabled" },
    { "value": { "value": "1" }, "context": "Default", "name": "addtl_worker_count" },
    { "value": { "value": "1" }, "context": "Default", "name": "less_worker_count" },
    { "value": { "value": "5" }, "context": "Default", "name": "autoscaler_max_count" }
]
