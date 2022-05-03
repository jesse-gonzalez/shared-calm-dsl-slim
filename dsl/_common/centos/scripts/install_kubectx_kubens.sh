# install git if not already done
sudo yum install -y git

# configure kubectx and kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# add kubens and kubectx aliases
sudo echo "alias kns='kubens'" | tee -a ~/.bashrc ~/.zshrc
sudo echo "alias kctx='kubectx'" | tee -a ~/.bashrc ~/.zshrc

# quick validation
kubens --help
kubectx --help

# install fzf command to switch between contexts easily

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
sudo echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' | tee -a ~/.bashrc
