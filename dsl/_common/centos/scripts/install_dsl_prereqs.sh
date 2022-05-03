echo "Install epel-release"
rpm -q epel-release || sudo yum -y install epel-release
sudo yum makecache

echo "Install Python3"
rpm -q python36 || sudo yum -y install python36 python-pip python3-devel

echo "Install Docker"
which docker || { curl -fsSL https://get.docker.com/ | sh; sudo systemctl start docker; sudo systemctl enable docker; }

echo "Update User to run docker"
sudo usermod -aG docker @@{Nutanix.username}@@

echo "Install virtualenv"
sudo pip3 install virtualenv
