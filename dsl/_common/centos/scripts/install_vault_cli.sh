sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
sudo yum -y install vault

# test and validate
# vault server -dev
# vault kv put secret/hello foo=world excited=yes
# vault kv get secret/hello
# vault kv get -format=json secret/hello | jq -r .data.data.excited
# vault kv get -field=excited secret/hello
# vault kv get -field=excited secret/hello
# vault secrets enable -path=kv kv
# vault secrets list
