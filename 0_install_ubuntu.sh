#!/usr/bin/env bash
set -euo pipefail

# Détection de l'architecture système (x86_64 ou aarch64/arm64)
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    DEB_ARCH="amd64"
    GO_ARCH="amd64"
    LAZYGIT_ARCH="x86_64"
    DELTA_ARCH="x86_64-unknown-linux-musl"
    ;;
  aarch64|arm64)
    DEB_ARCH="arm64"
    GO_ARCH="arm64"
    LAZYGIT_ARCH="arm64"
    DELTA_ARCH="aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "❌ Architecture non supportée : $ARCH"
    exit 1
    ;;
esac
echo "==> Architecture détectée : ${ARCH} (${DEB_ARCH})"

echo "==> Mise à jour des paquets..."
sudo apt update && sudo apt upgrade -y

echo "==> Installation des paquets de base..."
sudo apt install -y \
  zsh \
  tmux \
  git \
  curl \
  wget \
  unzip \
  tar \
  build-essential \
  ca-certificates \
  gnupg \
  lsb-release

echo "==> Installation des CLI modernes..."
sudo apt install -y \
  ripgrep \
  fd-find \
  jq \
  fzf \
  bat \
  eza

# Sur Ubuntu, fd-find s'appelle fdfind — on crée un alias permanent
if ! command -v fd >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which fdfind)" "$HOME/.local/bin/fd"
fi

# Sur Ubuntu, bat s'appelle batcat — idem
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
  mkdir -p "$HOME/.local/bin"
  ln -sf "$(which batcat)" "$HOME/.local/bin/bat"
fi

echo "==> Installation de Neovim (version récente)..."
if ! nvim --version >/dev/null 2>&1 || [ ! -f "/usr/local/share/nvim/syntax/syntax.vim" ]; then
  NVIM_VERSION="$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name')"
  if [ "$ARCH" = "x86_64" ]; then
    # AppImage pour x86_64
    curl -Lo /tmp/nvim.appimage \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.appimage"
    chmod u+x /tmp/nvim.appimage
    sudo mv /tmp/nvim.appimage /usr/local/bin/nvim
  else
    # Tarball pour ARM64 (AppImage non compatible ARM64)
    curl -Lo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-arm64.tar.gz"
    tar -xf /tmp/nvim.tar.gz -C /tmp
    sudo mv /tmp/nvim-linux-arm64/bin/nvim /usr/local/bin/nvim
    sudo mv /tmp/nvim-linux-arm64/lib/nvim /usr/local/lib/ 2>/dev/null || true
    sudo mkdir -p /usr/local/share/nvim
    sudo cp -r /tmp/nvim-linux-arm64/share/nvim/. /usr/local/share/nvim/
    rm -rf /tmp/nvim.tar.gz /tmp/nvim-linux-arm64
  fi
fi

echo "==> Installation de Starship..."
if ! command -v starship >/dev/null 2>&1; then
  curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

echo "==> Installation de lazygit..."
if ! lazygit --version >/dev/null 2>&1; then
  LAZYGIT_VERSION="$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest | jq -r '.tag_name')"
  curl -Lo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION#v}_Linux_${LAZYGIT_ARCH}.tar.gz"
  tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit -D -t /usr/local/bin/
  rm -f /tmp/lazygit.tar.gz /tmp/lazygit
fi

echo "==> Installation de Go..."
if ! command -v go >/dev/null 2>&1; then
  GO_VERSION="$(curl -fsSL 'https://go.dev/dl/?mode=json' | jq -r '.[0].version')"
  curl -Lo /tmp/go.tar.gz "https://go.dev/dl/${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf /tmp/go.tar.gz
  rm /tmp/go.tar.gz
  echo 'export PATH="$PATH:/usr/local/go/bin"' >> "$HOME/.profile"
fi

echo "==> Installation de kubectl..."
if ! kubectl version --client >/dev/null 2>&1; then
  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${DEB_ARCH}/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
fi

echo "==> Installation de kubectx et kubens..."
if ! command -v kubectx >/dev/null 2>&1; then
  KUBECTX_VERSION="$(curl -fsSL https://api.github.com/repos/ahmetb/kubectx/releases/latest | jq -r '.tag_name')"
  KUBECTX_ARCH="$([ "$ARCH" = "x86_64" ] && echo "x86_64" || echo "arm64")"
  for tool in kubectx kubens; do
    curl -Lo "/tmp/${tool}.tar.gz" \
      "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/${tool}_${KUBECTX_VERSION}_linux_${KUBECTX_ARCH}.tar.gz"
    tar -xf "/tmp/${tool}.tar.gz" -C /tmp "${tool}"
    sudo install "/tmp/${tool}" -D -t /usr/local/bin/
    rm -f "/tmp/${tool}.tar.gz" "/tmp/${tool}"
  done
fi

echo "==> Installation de k9s..."
if ! k9s version >/dev/null 2>&1; then
  K9S_VERSION="$(curl -fsSL https://api.github.com/repos/derailed/k9s/releases/latest | jq -r '.tag_name')"
  curl -Lo /tmp/k9s.tar.gz \
    "https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_${DEB_ARCH}.tar.gz"
  tar -xf /tmp/k9s.tar.gz -C /tmp k9s
  sudo install /tmp/k9s -D -t /usr/local/bin/
  rm -f /tmp/k9s.tar.gz /tmp/k9s
fi

echo "==> Installation de helm..."
if ! command -v helm >/dev/null 2>&1; then
  curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

echo "==> Installation de kind..."
if ! kind --version >/dev/null 2>&1; then
  KIND_VERSION="$(curl -fsSL https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name')"
  curl -Lo /tmp/kind \
    "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${DEB_ARCH}"
  sudo install /tmp/kind -D -t /usr/local/bin/
  rm /tmp/kind
fi

echo "==> Installation de Docker Engine..."
if ! command -v docker >/dev/null 2>&1; then
  # Ajout de la clé GPG et du dépôt officiel Docker
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch=${DEB_ARCH} signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
  # Permettre d'utiliser docker sans sudo
  sudo usermod -aG docker "$USER"
  echo "⚠️  Déconnecte-toi et reconnecte-toi pour que le groupe 'docker' soit pris en compte."
fi

echo "==> Installation de yq..."
if ! yq --version >/dev/null 2>&1; then
  YQ_VERSION="$(curl -fsSL https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.tag_name')"
  curl -Lo /tmp/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${DEB_ARCH}"
  sudo install /tmp/yq -D -t /usr/local/bin/
  rm /tmp/yq
fi


echo "==> Définir zsh comme shell par défaut..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

echo ""
echo "✅ Installation WSL Ubuntu terminée."
echo "   Redémarre ton terminal."
