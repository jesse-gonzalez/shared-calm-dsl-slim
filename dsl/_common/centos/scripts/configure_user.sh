#chmod 700 ~/.ssh
echo 'set -o vi' | tee -a ~/.bashrc ~/.zshrc
echo 'alias vi="vim"' | tee -a ~/.bashrc ~/.zshrc
echo 'StrictHostKeyChecking no' > ~/.ssh/config
chmod 600 ~/.ssh/config

echo "Create SSH Keys"
echo "@@{Nutanix.secret}@@" > ~/.ssh/id_rsa
echo "@@{nutanix_public_key}@@" > ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/id_rsa*

