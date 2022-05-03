echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-port @@{pc_instance_port}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Get kubeconfig"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@_@@{instance_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

chmod 600 ~/@@{k8s_cluster_name}@@_@@{instance_name}@@.cfg
