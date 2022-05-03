"""
Calm Endpoint Linux Scripting Host
"""

import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context
from calm.dsl.runbooks import read_local_file
from calm.dsl.runbooks import basic_cred
from calm.dsl.runbooks import CalmEndpoint as Endpoint

ContextObj = get_context()
init_data = ContextObj.get_init_config()

KarbonAdminWsIP = read_local_file("karbon_admin_ws_ip")

NutanixKeyUser = os.environ['NUTANIX_KEY_USER']
NutanixKey = read_local_file("nutanix_key")
NutanixCred = basic_cred(
                    NutanixKeyUser,
                    name="Nutanix",
                    type="KEY",
                    password=NutanixKey,
                    default=True
                )

DslLinuxEndpoint = Endpoint.Linux.ip(
    [KarbonAdminWsIP], cred=NutanixCred
)
