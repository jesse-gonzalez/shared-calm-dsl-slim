import os

variable_list = [
    { "value": { "value": os.getenv("DOMAIN_NAME") }, "context": "Default", "name": "domain_name" },
    { "value": { "value": os.getenv("PC_PORT") }, "context": "Default", "name": "pc_instance_port" },
    { "value": { "value": os.getenv("PC_IP_ADDRESS") }, "context": "Default", "name": "pc_instance_ip" },
    # Alternatives if vLAN_110 = "10.59.110.50-10.59.110.54", if vLAN_115 "10.59.115.50-10.59.115.54"
    #{ "value": { "value": os.getenv("KARBON_LB_ADDRESSPOOL") }, "context": "Default", "name": "metallb_network_range" },
]
