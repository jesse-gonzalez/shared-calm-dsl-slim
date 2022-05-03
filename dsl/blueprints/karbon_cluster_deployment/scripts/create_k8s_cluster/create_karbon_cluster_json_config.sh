if [ "@@{cni_name}@@" == "Flannel" ]
then
echo '{
  "cni_config": {
    "flannel_config": {},
    "pod_ipv4_cidr": "172.20.0.0/16",
    "service_ipv4_cidr": "172.19.0.0/16"
  },' > karbon_testing.json

elif [ "@@{cni_name}@@" == "Calico" ]
then
echo '{
  "cni_config": {
    "calico_config": {
      "ip_pool_configs": [
        {
           "cidr": "172.20.0.0/16"
        }
      ]
    }
  },' > karbon_testing.json
fi

if [ "@@{cluster_type}@@" == "Production - Multi-Master Active/Passive" ]
then
echo '
  "etcd_config": {
    "node_pools": [
      {
        "ahv_config": {
          "cpu": 2,
          "disk_mib": 40960,
          "memory_mib": 8192,
          "network_uuid": "@@{network_uuid}@@",
          "prism_element_cluster_uuid": "@@{prism_element_uuid}@@"
        },
        "name": "@@{k8s_cluster_name}@@-etcd-pool-01",
        "node_os_version": "@@{node_os_version}@@",
        "num_instances": 3
      }
    ]
  },
  "masters_config": {
    "active_passive_config": {
      "external_ipv4_address": "@@{external_ipv4_addr}@@"
    },
    "node_pools": [
      {
        "ahv_config": {
          "cpu": 2,
          "disk_mib": 122880,
          "memory_mib": 4096,
          "network_uuid": "@@{network_uuid}@@",
          "prism_element_cluster_uuid": "@@{prism_element_uuid}@@"
        },
        "name": "@@{k8s_cluster_name}@@-master-pool-01",
        "node_os_version": "@@{node_os_version}@@",
        "num_instances": 2
      }
    ]
  },' >> karbon_testing.json

elif [ "@@{cluster_type}@@" == "Development" ]
then
echo '
  "etcd_config": {
    "node_pools": [
      {
        "ahv_config": {
          "cpu": 2,
          "disk_mib": 40960,
          "memory_mib": 8192,
          "network_uuid": "@@{network_uuid}@@",
          "prism_element_cluster_uuid": "@@{prism_element_uuid}@@"
        },
        "name": "@@{k8s_cluster_name}@@-etcd-pool-01",
        "node_os_version": "@@{node_os_version}@@",
        "num_instances": 1
      }
    ]
  },
  "masters_config": {
    "single_master_config": {},
    "node_pools": [
      {
        "ahv_config": {
          "cpu": 1,
          "disk_mib": 122880,
          "memory_mib": 8192,
          "network_uuid": "@@{network_uuid}@@",
          "prism_element_cluster_uuid": "@@{prism_element_uuid}@@"
        },
        "name": "@@{k8s_cluster_name}@@-master-pool-01",
        "node_os_version": "@@{node_os_version}@@",
        "num_instances": 1
      }
    ]
  },' >> karbon_testing.json
fi

echo '
  "name": "@@{k8s_cluster_name}@@",
  "metadata": {
    "api_version": "v1.0.0"
  },
  "storage_class_config": {
    "default_storage_class": true,
    "name": "default-storageclass",
    "reclaim_policy": "Delete",
    "volumes_config": {
      "file_system": "ext4",
      "flash_mode": false,
      "password": "@@{Prism Element User.secret}@@",
      "prism_element_cluster_uuid": "@@{prism_element_uuid}@@",
      "storage_container": "@@{storage_container_name}@@",
      "username": "@@{Prism Element User.username}@@"
    }
  },
  "version": "@@{k8s_version}@@",
  "workers_config": {
    "node_pools": [
      {
        "ahv_config": {
          "cpu": 4,
          "disk_mib": 122880,
          "memory_mib": 8192,
          "network_uuid": "@@{network_uuid}@@",
          "prism_element_cluster_uuid": "@@{prism_element_uuid}@@"
        },
        "name": "@@{k8s_cluster_name}@@-worker-pool-01",
        "node_os_version": "@@{node_os_version}@@",
        "num_instances": @@{worker_count}@@
      }
    ]
  }
}' >> karbon_testing.json


# print json output
cat karbon_testing.json
