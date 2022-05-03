# configure krew package manager

# install git if not already out there
yum install -y git

## commands straight from docs https://krew.sigs.k8s.io/docs/user-guide/setup/install/

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
)

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

echo '' | tee -a ~/.bashrc ~/.zshrc
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' | tee -a ~/.bashrc ~/.zshrc
echo 'alias krew="kubectl krew"' | tee -a ~/.bashrc ~/.zshrc
echo '' | tee -a ~/.bashrc ~/.zshrc

# install ideal krew plugins
kubectl krew update
kubectl krew search
kubectl krew install access-matrix # ideal for seeing who has access to what across the cluster
kubectl krew install images # ability to view all images
kubectl krew install allctx # configure allctxx command
kubectl krew install ca-cert # install ca-cert
kubectl krew install cert-manager # Manage cert-manager resources inside your cluster
kubectl krew install whoami # determine active user subject details of context
kubectl krew install config-cleanup # Auto cleanup of config file
