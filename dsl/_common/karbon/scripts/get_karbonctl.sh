echo "Get karbonctl"
sshpass -p '@@{Nutanix Password.secret}@@' scp nutanix@@@{pc_instance_ip}@@:/home/nutanix/karbon/karbonctl .

sudo cp ~/karbonctl /usr/local/bin/karbonctl
sudo chmod +x /usr/local/bin/karbonctl
sudo ln -s /usr/local/bin/karbonctl /usr/bin/karbonctl

echo 'alias karbonctl="~/karbonctl"' | tee -a ~/.bashrc ~/.zshrc
