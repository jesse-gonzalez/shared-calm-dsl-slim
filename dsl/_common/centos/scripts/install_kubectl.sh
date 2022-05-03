echo "[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | sudo tee /etc/yum.repos.d/kubernetes.repo

sudo yum install -y kubectl

# install bash-completion if not already done
sudo yum install -y bash-completion

# configure default .kube config path
sudo mkdir -p ~/.kube
sudo chown $(id -u):$(id -g) $HOME/.kube
touch $HOME/.kube/config

# configure bashrc

echo "source <(kubectl completion bash)" | tee -a ~/.bashrc ~/.zshrc
echo "alias k='kubectl'" | tee -a ~/.bashrc ~/.zshrc
echo "complete -F __start_kubectl k" | tee -a ~/.bashrc ~/.zshrc
echo "export do='--dry-run=client -o yaml'"  | tee -a ~/.bashrc ~/.zshrc
