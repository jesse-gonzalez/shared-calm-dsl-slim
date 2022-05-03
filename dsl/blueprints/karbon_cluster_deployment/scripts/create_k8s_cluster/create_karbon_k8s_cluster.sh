source ~/.bashrc

echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Create Karbon K8s cluster"
karbonctl cluster create --file-path karbon_testing.json
