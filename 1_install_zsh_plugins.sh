#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="${HOME}/.local/share/zsh/plugins"
echo "==> Installation des plugins Zsh dans ${PLUGIN_DIR}..."

mkdir -p "${PLUGIN_DIR}"

# zsh-autosuggestions
if [ ! -d "${PLUGIN_DIR}/zsh-autosuggestions" ]; then
  echo "  -> zsh-autosuggestions..."
  git clone --depth=1 \
    https://github.com/zsh-users/zsh-autosuggestions.git \
    "${PLUGIN_DIR}/zsh-autosuggestions"
else
  echo "  -> zsh-autosuggestions déjà présent, mise à jour..."
  git -C "${PLUGIN_DIR}/zsh-autosuggestions" pull --ff-only 2>/dev/null || true
fi

# zsh-syntax-highlighting (doit être sourcé EN DERNIER dans .zshrc)
if [ ! -d "${PLUGIN_DIR}/zsh-syntax-highlighting" ]; then
  echo "  -> zsh-syntax-highlighting..."
  git clone --depth=1 \
    https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "${PLUGIN_DIR}/zsh-syntax-highlighting"
else
  echo "  -> zsh-syntax-highlighting déjà présent, mise à jour..."
  git -C "${PLUGIN_DIR}/zsh-syntax-highlighting" pull --ff-only 2>/dev/null || true
fi

echo "==> Plugins Zsh installés."
