"""
Calm Endpoint Windows Scripting Host
"""

import os
from calm.dsl.builtins import *
from calm.dsl.config import get_context
from calm.dsl.runbooks import read_local_file
from calm.dsl.runbooks import basic_cred
from calm.dsl.runbooks import CalmEndpoint as Endpoint

ContextObj = get_context()
init_data = ContextObj.get_init_config()

WindowsScriptingHostIP = os.getenv("WINDOWS_SCRIPTING_HOST_IP")
WindowsScriptingHostUser = os.getenv("WINDOWS_SCRIPTING_HOST_USER")
WindowsScriptingHostPassword = os.getenv("WINDOWS_SCRIPTING_HOST_PASS")

WindowsScriptingHostCred = basic_cred(
                    WindowsScriptingHostUser,
                    name="Windows Host",
                    type="Password",
                    password=WindowsScriptingHostPassword,
                    default=True
                )

Cred = basic_cred(WindowsScriptingHostUser, WindowsScriptingHostPassword, name="endpoint_cred")
DslWindowsEndpoint = Endpoint.Windows.ip(
    [WindowsScriptingHostIP], connection_protocol="HTTP", cred=Cred
)
