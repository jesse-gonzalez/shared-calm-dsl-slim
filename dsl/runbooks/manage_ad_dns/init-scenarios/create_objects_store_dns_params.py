import os

variable_list = [
   { "value": os.getenv("DOMAIN_NAME"), "context": "Default", "name": "domain_name" },
   { "value": os.getenv("DNS"), "context": "Default", "name": "dns_server" },
   { "value": os.getenv("OBJECTS_STORE_DNS_SHORT"), "context": "Default", "name": "dns_name" },
   { "value": os.getenv("OBJECTS_STORE_PUBLIC_IP"), "context": "Default", "name": "dns_ip_address" },
   { "value": "Create", "context": "Default", "name": "update_type" }
]

