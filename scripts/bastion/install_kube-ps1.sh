# configure kube-ps1
git clone https://github.com/jonmosco/kube-ps1 /opt/kube-ps1

echo "source /opt/kube-ps1/kube-ps1.sh" | tee -a ~/.bashrc
echo "export KUBE_PS1_SYMBOL_ENABLE=false" | tee -a ~/.bashrc
echo "PS1='[\W \$(kube_ps1)] \n\\$ '" | tee -a ~/.bashrc
