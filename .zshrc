# Pour mettre zsh en default : chsh -s $(which zsh)

# Créer une nouvelle session avec un nom unique basé sur l'heure
if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [[ $- == *i* ]]; then
  session_name="term-$(date +%s)"
  tmux new-session -s "$session_name"
fi

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

# ─── Autocomplétion ───────────────────────────────────────────
autoload -Uz compinit

# ─── Aliases — Navigation ─────────────────────────────────────
alias ll="eza -lah --git --icons"
alias cdf='cd $(fd --type d | fzf)'

# ─── Aliases — Raccourcis quotidiens ──────────────────────────
alias g="git"
alias v="nvim"
alias k="kubectl"
alias lg="lazygit"
alias d="docker"
alias dc="docker compose"
alias fd='fdfind'

# ─── Aliases — Kubernetes ─────────────────────────────────────
alias kn="kubens"
alias kx="kubectx"

# Go
export GOPATH="${HOME}/go"
export PATH="${PATH}:/usr/local/go/bin:${GOPATH}/bin"

# ─── Fonctions shell DevOps ───────────────────────────────────
# Logs d'un pod avec recherche fzf si aucun pod spécifié
klogs() {
  if [ -z "$1" ]; then
    local pod
    pod=$(kubectl get pods --no-headers | fzf | awk '{print $1"/"$2}')
    local ns="${pod%%/*}"
    local name="${pod##*/}"
    kubectl logs -f -n "${ns}" "${name}"
  else
    kubectl logs -f "$@"
  fi
}

# Ctrl+R → recherche dans l'historique avec fzf
# Ctrl+T → recherche de fichiers avec fzf
# Alt+C  → navigation dans les dossiers avec fzf
[ -f "/usr/share/doc/fzf/examples/key-bindings.zsh" ] && source "/usr/share/doc/fzf/examples/key-bindings.zsh"

# ─── Plugins Zsh ──────────────────────────────────────────────
ZSH_PLUGIN_DIR="${HOME}/.local/share/zsh/plugins"

if [ -f "${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [ -f "${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "${ZSH_PLUGIN_DIR}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi


eval "$(starship init zsh)"
