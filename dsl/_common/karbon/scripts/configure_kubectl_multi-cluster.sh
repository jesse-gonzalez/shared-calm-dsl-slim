# update kubeconfig to support multiple clusters
sudo mkdir -p ~/.kube

echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG for all clusters"
# loop through karbon clusters and set kubeconfig
karbonctl cluster list --output json | jq -r '.Payload' | jq -r '.[].cluster_metadata.name' | xargs -I {} sh -c "karbonctl cluster kubeconfig --cluster-name {} > '$HOME/.kube/{}.cfg'"
sudo ls ~/.kube

# Load extra functions and helpers
# Local environment variables and settings are kept in .localrc
# These should not go in source control (public)
cat <<EOF | tee -a ~/.bashrc ~/.zshrc
for files in ~/.{bash_completion,kubectl_aliases,bash_aliases,bash_functions}; do
  if [[ -r "\$files" ]] && [[ -f "\$files" ]]; then
    # shellcheck disable=SC1090
    source "\$files"
  fi
done
EOF

cat <<EOF | sudo tee ~/.bash_functions

## function to loop through karbon clusters and get latest kubeconfigs
function refresh_karbon_clusters() {
  karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password "@@{Prism Central User.secret}@@"
  karbonctl cluster list --output json | jq -r '.Payload' | jq -r '.[].cluster_metadata.name' | xargs -I {} sh -c "karbonctl cluster kubeconfig --cluster-name {} >| '$HOME/.kube/{}.cfg'"
  source ~/.bashrc
  kubectl allctx get nodes
}

EOF

echo "## updating bashrc to loop through kubeconfig files from all clusters and add to overall context"
echo "export KUBECONFIG_HOME=\$HOME/.kube" | tee -a ~/.bashrc ~/.zshrc
echo "export KUBECONFIG_LIST=\$( ls \$HOME/.kube/*.cfg | cut -d/ -f5 | xargs -I {} echo \$KUBECONFIG_HOME/{} )" | tee -a ~/.bashrc ~/.zshrc ## loop through kubectl configs and update kubeconfig var
echo "export KUBECONFIG=\$( echo \$KUBECONFIG_LIST | tr ' ' ':' )" | tee -a ~/.bashrc ~/.zshrc
echo "kubectl config view --flatten >| /$HOME/.kube/config" | tee -a ~/.bashrc ~/.zshrc ## merge configs to standalone config file
echo "export KUBECONFIG=\$HOME/.kube/config" | tee -a ~/.bashrc ~/.zshrc ## reset kubeconfig path

# update bashrc to auto cleanup stale kubectl configs. Depends on Krew kubectl plugin manager.
echo "kubectl config-cleanup --clusters --users --print-removed -o=jsonpath='{ range.contexts[*] }{ .context.cluster }{\"\\n\"}' -t 2 | xargs -I {} rm -f ~/.kube/{}.cfg"  | tee -a ~/.bashrc ~/.zshrc # cleanup any configs that are no longer accessible
