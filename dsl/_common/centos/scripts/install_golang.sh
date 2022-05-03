# install wget if not already out there
sudo yum install -y wget

# install golang for testing / development
sudo wget https://golang.org/dl/go1.16.3.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz

echo "export PATH=\$PATH:/usr/local/go/bin" >> $HOME/.bashrc

export PATH=$PATH:/usr/local/go/bin

# validate
go version
