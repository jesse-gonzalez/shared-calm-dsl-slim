
# install wget if not already out there
sudo yum install -y wget

# get kubectl aliases to shorten kubectl commands like - kgpo - kubectl get pods
sudo wget -O ~/.kubectl_aliases https://rawgit.com/ahmetb/kubectl-alias/master/.kubectl_aliases
echo '[ -f ~/.kubectl_aliases ] && source ~/.kubectl_aliases' | tee -a ~/.bashrc ~/.zshrc

# other aliases

echo 'alias ke="kubectl explain"' | tee -a ~/.bashrc ~/.zshrc
echo 'alias ker="kubectl explain --recursive"' | tee -a ~/.bashrc ~/.zshrc
