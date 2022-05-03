echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echco "Delete Karbon Cluster"
echo 'Y' | ./karbonctl cluster delete --cluster-name @@{k8s_cluster_name}@@ --skip-prechecks
