echo "** Installing python-pip..."
sudo yum install -y python-pip

echo "** Upgrade pip..."
sudo pip install --upgrade pip

echo "** Install docker-compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

