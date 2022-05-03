# Download Openshift Installer
curl --silent --location "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-install-linux.tar.gz" | tar xz -C /tmp
sudo mv /tmp/openshift-install /usr/local/bin
sudo chmod +x /usr/local/bin/openshift-install

openshift-install -h

# Download Openshift Client
curl --silent --location "https://mirror.openshift.com/pub/openshift-v4/clients/ocp/stable/openshift-client-linux.tar.gz" | tar xz -C /tmp
sudo mv /tmp/oc /usr/local/bin
sudo chmod +x /usr/local/bin/oc

oc -h
