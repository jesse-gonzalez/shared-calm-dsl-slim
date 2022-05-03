import os

## This will create a shorter version for ingress., i.e., *.kalm-main.ntnxlab.local vs. *.kalm-main-12-3.ntnxlab.local
## Using this scenario for App / Argo / Jenkins workflow
WILDCARD_INGRESS_DOMAIN_STUB = "*." + os.getenv("WILDCARD_INGRESS_DNS_SHORT_SIMPLE")

variable_list = [
   { "value": os.getenv("DOMAIN_NAME"), "context": "Default", "name": "domain_name" },
   { "value": os.getenv("DNS"), "context": "Default", "name": "dns_server" },
   { "value": WILDCARD_INGRESS_DOMAIN_STUB, "context": "Default", "name": "dns_name" },
   { "value": os.getenv("WILDCARD_INGRESS_IP"), "context": "Default", "name": "dns_ip_address" },
   { "value": "Create", "context": "Default", "name": "update_type" }
]
