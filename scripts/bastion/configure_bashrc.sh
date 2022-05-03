#chmod 700 ~/.ssh

echo '' | tee -a ~/.bashrc
echo 'set -o vi' | tee -a ~/.bashrc
echo 'alias vi="vim"' | tee -a ~/.bashrc
echo 'alias reload="source ~/.bashrc"' | tee -a ~/.bashrc
echo 'source /etc/profile.d/bash_completion.sh' | tee -a ~/.bashrc

echo '' | tee -a ~/.bashrc

if [ ! -d "~/.ssh" ]; then
  mkdir -p ~/.ssh
  echo 'StrictHostKeyChecking no' > ~/.ssh/config
  chmod 600 ~/.ssh/config
fi

# configure default .kube config path
sudo mkdir -p ~/.kube
sudo chown $(id -u):$(id -g) $HOME/.kube
touch $HOME/.kube/config


echo '' | tee -a ~/.bashrc
echo "source <(kubectl completion bash)" | tee -a ~/.bashrc
echo "alias k='kubectl'" | tee -a ~/.bashrc
echo "complete -F __start_kubectl k" | tee -a ~/.bashrc
echo "export do='--dry-run=client -o yaml'"  | tee -a ~/.bashrc
echo '' | tee -a ~/.bashrc

echo '' | tee -a ~/.bashrc
echo "## updating bashrc to loop through kubeconfig files from all clusters and add to overall context"
echo "if [ -f \$HOME/.kube/config ]; then" | tee -a ~/.bashrc ~/.zshrc
echo "  export KUBECONFIG_HOME=\$HOME/.kube" | tee -a ~/.bashrc ~/.zshrc
echo "  export KUBECONFIG=\$( ls \$HOME/.kube/*.cfg | cut -d/ -f4 | xargs -I {} echo \$KUBECONFIG_HOME/{} | tr '\n' ':' )" | tee -a ~/.bashrc ~/.zshrc ## loop through kubectl configs and update kubeconfig var
echo "  kubectl config view --flatten >| \$HOME/.kube/config" | tee -a ~/.bashrc ~/.zshrc ## merge configs to standalone config file
echo "  export KUBECONFIG=\$HOME/.kube/config" | tee -a ~/.bashrc ~/.zshrc ## reset kubeconfig path
echo "  chmod 600 \$HOME/.kube/config" | tee -a ~/.bashrc ~/.zshrc ## reset kubeconfig path
echo "  kubectl config-cleanup --clusters --users --print-removed -o=jsonpath='{ range.contexts[*] }{ .context.cluster }{\"\\n\"}' -t 2 | xargs -I {} rm -f ~/.kube/{}.cfg"  | tee -a ~/.bashrc ~/.zshrc # cleanup any configs that are no longer accessible
echo "fi" | tee -a ~/.bashrc ~/.zshrc
echo '' | tee -a ~/.bashrc ~/.zshrc
