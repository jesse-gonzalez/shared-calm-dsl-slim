## install helm 3

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm -rf get_helm.sh
helm version

## install sops

curl -sSL -o /usr/local/bin/sops https://github.com/mozilla/sops/releases/download/v3.7.1/sops-v3.7.1.linux
chmod +x /usr/local/bin/sops
sops -h

## install helm plugins - secrets

helm plugin install https://github.com/futuresimple/helm-secrets && \
helm secrets -h

## install helm plugins - diff
helm plugin install https://github.com/databus23/helm-diff && \
helm diff -h

## install helmfile

curl -sSL -o /usr/local/bin/helmfile https://github.com/roboll/helmfile/releases/latest/download/helmfile_linux_amd64
chmod +x /usr/local/bin/helmfile
helmfile version
