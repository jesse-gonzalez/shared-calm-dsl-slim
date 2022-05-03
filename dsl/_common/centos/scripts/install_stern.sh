# install wget if not already out there
sudo yum install -y wget

# configure stern to simplify logging
sudo wget -O /opt/stern https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
sudo chmod +x /opt/stern
sudo ln -s /opt/stern /usr/local/bin/stern

# quick validation
stern --help

echo 'alias stern="stern --tail 10 --since 5s"' | tee -a ~/.bashrc ~/.zshrc
