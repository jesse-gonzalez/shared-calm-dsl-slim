echo "** Install Required Packages..."
sudo yum install -y yum-utils
sudo yum install -y epel-release.noarch
sudo yum install -y httpd-tools

echo "** Adding Docker Repo..."
sudo yum-config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo

echo "** Set apt-cache policy for docker-ce..."
sudo yum-config-manager --enable docker-ce-nightly

echo "** Installing Docker CE..."
sudo yum install -y docker-ce
sudo yum makecache fast

echo "** Adding current user to docker group..."
sudo usermod -aG docker @@{Nutanix.username}@@

echo "** Starting Docker CE..."
sudo service docker enable
sudo service docker start

