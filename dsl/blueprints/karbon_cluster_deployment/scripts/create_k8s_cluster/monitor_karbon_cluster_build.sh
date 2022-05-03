echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Checking Build Status with 15 second intervals"

build_status=$(./karbonctl cluster tasks list --cluster-name @@{k8s_cluster_name}@@ --output json | jq -r '[ .[] | select( .operation | match("DeployK8s")) ]' | jq -r '.[].percent_complete')
echo "Build Status: $build_status percent complete"

while [ $build_status -lt 100 ];do

    sleep 15
	previous_build_status=$build_status
    build_status=$(./karbonctl cluster tasks list --cluster-name @@{k8s_cluster_name}@@ --output json | jq -r '[ .[] | select( .operation | match("DeployK8s")) ]' | jq -r '.[].percent_complete')
    if [ -z "${build_status}" ]
	then
		build_status=$previous_build_status
	fi
    echo "Build Status: $build_status percent complete"

done
