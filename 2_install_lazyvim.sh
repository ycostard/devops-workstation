#!/usr/bin/env bash
set -euo pipefail

NVIM_DIR="${HOME}/.config/nvim"
LAZYVIM_URL="https://github.com/LazyVim/starter"

echo "==> Configuration de Neovim + LazyVim..."

if [ -f "${NVIM_DIR}/init.lua" ]; then
  echo "  -> Neovim déjà configuré dans ${NVIM_DIR}. Passage."
else
  # Supprimer le dossier s'il existe mais est vide ou incomplet
  rm -rf "${NVIM_DIR}"
  echo "  -> Clonage du starter LazyVim..."
  git clone --depth=1 "${LAZYVIM_URL}" "${NVIM_DIR}"
  # Supprimer le .git pour permettre de versionner notre propre config
  rm -rf "${NVIM_DIR}/.git"
  echo "  -> LazyVim installé."
fi



echo "==> Neovim configuré"