# Download Calm DSL latest from hub.docker.com
FROM ntnx/calm-dsl:latest

# Add packages needed for development
RUN apk update \
    && apk upgrade \
    && apk add --no-cache make \
        docker \
        git \
        yq \
        curl \
        unzip \
        tar \
        openssl \
        gnupg \
        gpg \
        ca-certificates \
        tree \
        fzf \
        vim \
        bash-completion \
        zsh \
        perl \
        ncurses \
        jq

## configure zsh
RUN apk add --no-cache zsh \
    && sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

COPY ./scripts/dotfiles /root

# ## install utils
COPY ./scripts/bastion /tmp
WORKDIR /tmp
RUN chmod +x *.sh \
    && ./install_helm.sh \
    && ./install_kubectl.sh \
    && ./install_kubectx_kubens.sh \
    && ./install_kube-ps1.sh \
    && ./install_kubectl_krew.sh \
    && ./configure_bashrc.sh \
    && ./configure_vimrc.sh \
    && ./configure_kubectl_aliases.sh \
    && ./install_argocd_cli.sh \
    && ./install_stern.sh

## import local gpg key
COPY ./.local/common/sops_gpg_key /tmp
WORKDIR /tmp
RUN gpg --import sops_gpg_key
