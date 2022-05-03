echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Checking Build State"
build_state=$(./karbonctl cluster list --output json | jq -r ' .Payload' | jq -r '[ .[] | select( .cluster_metadata.name | match("@@{k8s_cluster_name}@@")) ]' | jq -r '.[].task_status')

if [ $build_state -ne 3 ];then
	echo "Cluster deploy FAILED"
    exit 1
else
	echo "Cluster deploy completed successfully"
    exit 0
fi
