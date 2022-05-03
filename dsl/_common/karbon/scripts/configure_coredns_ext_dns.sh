echo "Login karbonctl"
karbonctl login --pc-ip @@{pc_instance_ip}@@ --pc-username @@{Prism Central User.username}@@ --pc-password @@{Prism Central User.secret}@@

echo "Set KUBECONFIG"
karbonctl cluster kubeconfig --cluster-name @@{k8s_cluster_name}@@ | tee ~/@@{k8s_cluster_name}@@.cfg ~/.kube/@@{k8s_cluster_name}@@.cfg

export KUBECONFIG=~/@@{k8s_cluster_name}@@.cfg

# set dns search suffix and server in environment. allows ability to leverage Fileserver and Objects via DNS MUCH easier
# DNS_DOMAIN=ntnxlab.local
# DNS_SERVER=10.38.16.11

DNS_DOMAIN=@@{domain_name}@@
DNS_SERVER_IP=@@{dns_server}@@

cat <<EOF | kubectl apply -n kube-system -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns
  namespace: kube-system
data:
  Corefile: |
    .:53 {
        errors
        health
        prometheus :9153
        forward . /etc/resolv.conf
        cache 30
        reload
    }
    svc.cluster.local pod.cluster.local in-addr.arpa ip6.arpa {
        kubernetes cluster.local in-addr.arpa ip6.arpa {
          pods insecure
          fallthrough in-addr.arpa ip6.arpa
        }
        forward . /etc/resolv.conf
        errors
        loadbalance
    }
    $(echo $DNS_DOMAIN):53 {
        errors
        cache 30
        forward . $(echo $DNS_SERVER_IP)
    }
EOF

## rolling restart of coredns
kubectl rollout restart deployment coredns -n kube-system
kubectl rollout status deployment coredns -n kube-system -w

## rolling restart of csi contoller and node plugins
kubectl rollout restart statefulset csi-provisioner-ntnx-plugin -n ntnx-system
kubectl rollout status statefulset csi-provisioner-ntnx-plugin -n ntnx-system -w

kubectl rollout restart daemonset csi-node-ntnx-plugin -n ntnx-system
kubectl rollout status daemonset csi-node-ntnx-plugin -n ntnx-system -w
