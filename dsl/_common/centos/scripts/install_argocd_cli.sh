
# https://argoproj.github.io/argo-cd/cli_installation/#download-latest-version

sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo chmod +x /usr/local/bin/argocd

# alias to avoid grpc call failures

echo "alias argocd='argocd --grpc-web'" | tee -a ~/.bashrc ~/.zshrc
