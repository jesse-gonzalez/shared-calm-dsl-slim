import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context

KARBON_ADMIN_WS_IP = read_local_file("karbon_admin_ws_ip")

variable_list = [
   { "value": os.getenv("DOMAIN_NAME"), "context": "Default", "name": "domain_name" },
   { "value": os.getenv("DNS"), "context": "Default", "name": "dns_server" },
   { "value": os.getenv("KARBONCTL_WS_ENDPOINT_SHORT"), "context": "Default", "name": "dns_name" },
   { "value": KARBON_ADMIN_WS_IP, "context": "Default", "name": "dns_ip_address" },
   { "value": "Create", "context": "Default", "name": "update_type" }
]