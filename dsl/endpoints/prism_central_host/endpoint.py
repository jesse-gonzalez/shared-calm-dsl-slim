"""
Azure DevOps Host Endpoint
"""

import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context
from calm.dsl.runbooks import read_local_file
from calm.dsl.runbooks import CalmEndpoint as Endpoint

ContextObj = get_context()
init_data = ContextObj.get_init_config()

DomainName = os.getenv("DOMAIN_NAME") 

PrismCentralIP = os.getenv("PC_IP_ADDRESS")
PrismCentralPort = os.getenv("PC_PORT")
PrismCentralUser = os.environ['PRISM_CENTRAL_USER']
PrismCentralPassword = os.environ['PRISM_CENTRAL_PASS']

HTTPUrl = "https://" + PrismCentralIP + ":" + PrismCentralPort

DslHTTPEndpoint = Endpoint.HTTP(
    HTTPUrl, verify=False, auth=Endpoint.Auth(PrismCentralUser, PrismCentralPassword)
)
