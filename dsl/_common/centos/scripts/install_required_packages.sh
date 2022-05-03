echo "Install Packages"
echo "Install sshpass..."
sudo yum install -y sshpass
echo "Install wget..."
sudo yum install -y wget
echo "Install gcc..."
sudo yum install -y gcc
echo "Install openssl..."
sudo yum install -y openssl
sudo yum install -y openssl-devel
echo "Install tree..."
sudo yum install -y tree

echo "Install Latest Git Repos"
sudo yum -y install \
https://repo.ius.io/ius-release-el7.rpm \
https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

echo "Install Latest Git"
# remove older git if it already exists
sudo yum -y remove git
sudo yum -y install git224

echo "Install Direnv"
sudo yum -y install https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/direnv/2.12.2/1.fc28/x86_64/direnv-2.12.2-1.fc28.x86_64.rpm

echo "Install Direnv"
sudo yum -y install go
git clone https://github.com/direnv/direnv
cd direnv
make install
#sudo yum -y install https://kojipkgs.fedoraproject.org//vol/fedora_koji_archive02/packages/direnv/2.12.2/1.fc28/x86_64/direnv-2.12.2-1.fc28.x86_64.rpm
echo 'eval "$(direnv hook bash)"' | tee -a ~/.bashrc ~/.zshrc

echo 'alias reload="source ~/.bashrc"' | tee -a ~/.bashrc ~/.zshrc
