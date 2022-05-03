source calm-dsl/venv/bin/activate
calm init dsl -i @@{pc_instance_ip}@@ -P 9440 -u @@{Prism Central User.username}@@ -p @@{Prism Central User.secret}@@ -pj Default
calm update cache

mkdir -p ${HOME}/.calm/.local

echo "@@{Nutanix.secret}@@" > ${HOME}/.calm/.local/@@{Nutanix.username}@@_key
echo "@@{nutanix_public_key}@@" > ${HOME}/.calm/.local/@@{Nutanix.username}@@_public_key

