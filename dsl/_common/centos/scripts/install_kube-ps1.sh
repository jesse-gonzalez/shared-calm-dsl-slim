# install git if not already out there
sudo yum install -y git

# configure kube-ps1
sudo git clone https://github.com/jonmosco/kube-ps1 /opt/kube-ps1
echo "source /opt/kube-ps1/kube-ps1.sh" | tee -a ~/.bashrc ~/.zshrc
echo "PS1='[\u@\h \W \$(kube_ps1)] \n\\$ '" | tee -a ~/.bashrc ~/.zshrc
