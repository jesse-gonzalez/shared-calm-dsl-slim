"""
Calm DSL Manage AD DNS Runbook
"""

import os
from pathlib import Path
from calm.dsl.builtins import *
from calm.dsl.config   import get_context
from calm.dsl.runbooks import runbook, runbook_json
from calm.dsl.runbooks import RunbookTask as Task, RunbookVariable as Variable
from calm.dsl.runbooks import CalmEndpoint as Endpoint, ref

ContextObj = get_context()
init_data = ContextObj.get_init_config()

DNSServer = os.getenv("DNS")
DomainName = os.getenv("DOMAIN_NAME")

@runbook
def ManageADDNS():
    """
    Runbook to manage AD DNS
    """
    dns_name = Variable.Simple(
        "", 
        label="DNS Name", 
        description="Name to be managed in AD DNS",
        is_mandatory=True,
        runtime=True
    )
    dns_server = Variable.Simple(
        DNSServer,
        label="AD DNS Server",
        description="FQDN or IP address of the AD DNS server",
        is_hidden=True,
        runtime=False
    ) 
    domain_name = Variable.Simple(
        DomainName,
        label="Domain Name",
        description="Domain Name",
        is_hidden=True,
        runtime=False
    ) 
    dns_ip_address = Variable.Simple(
        "",
        label="DNS IP Address",
        description="IP Address for the DNS name to be managed",
        is_mandatory=True,
        runtime=True
    ) 
    update_type = Variable.WithOptions.Predefined.string(
        [
            "Create",
            "Delete"
        ],
        default="Create",
        label="Update Type",
        description="Select update to be performed",
        is_mandatory=True,
        runtime=True
    ) 

    Task.SetVariable.escript(
        name="Split IP",
        filename="scripts/split_ip.py",
        variables=["ip_number","reversed_ip"]
        )
    with Task.Decision.escript(
        name="Create or Delete Decision",
        filename="scripts/create_delete_decision.py",
    ) as d:

        if d.exit_code == 0:
            Task.Exec.powershell(
                name="Create IP Record",
                filename="scripts/create_ip.ps1",
                target=ref(Endpoint.use_existing("windows_scripting_host"))
            )
        if d.exit_code == 1:
            Task.Exec.powershell(
                name="Delete IP Record",
                filename="scripts/delete_ip.ps1",
                target=ref(Endpoint.use_existing("windows_scripting_host"))
            )



def main():
    print(runbook_json(ManageADDNS))


if __name__ == "__main__":
    main()
