# configure kubectx and kubens
git clone https://github.com/ahmetb/kubectx /opt/kubectx
ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# add kubens and kubectx aliases
echo '' | tee -a ~/.bashrc ~/.zshrc
echo "alias k='kubectl'" | tee -a ~/.bashrc ~/.zshrc
echo "alias kns='kubens'" | tee -a ~/.bashrc ~/.zshrc
echo "alias kctx='kubectx'" | tee -a ~/.bashrc ~/.zshrc
echo '' | tee -a ~/.bashrc ~/.zshrc

# quick validation
kubens --help
kubectx --help

# install fzf command to switch between contexts easily

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --all
echo '[ -f ~/.fzf.bash ] && source ~/.fzf.bash' | tee -a ~/.bashrc