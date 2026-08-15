# shellcheck disable=SC2296
export ZSH="$HOME/.oh-my-zsh"
export MANPAGER="nvim -c Man!"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-vi-mode
  fzf-tab
  docker
)

export PATH=$PATH:~/.local/bin:~/go/bin:~/.dotnet/tools:/snap/bin:/home/linuxbrew/.linuxbrew/bin/nvim:~/.local/share/JetBrains/Toolbox/scripts:"/mnt/c/Program Files/Neovide/":~/scripts
export BROWSER="/mnt/c/Program\\ Files\\ (x86)/Microsoft/Edge/Application/msedge.exe"
export MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"
export TESTINGPLATFORM_TELEMETRY_OPTOUT=1

alias nvide="neovide.exe"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit
source $ZSH/oh-my-zsh.sh

# Import local config
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# Disable sound notifications
unsetopt BEEP

zle -N sesh-sessions                 # statemnt for allowing `sesh-sessions` function be bind to keybind
bindkey -M emacs '\es' sesh-sessions #\es -> Alt-s
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

bindkey '^H' backward-kill-word

# zsh parameter completion for the dotnet CLI
_dotnet_zsh_complete() {
  local completions=("$(dotnet complete "$words")")
  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]; then
    _arguments '*::arguments: _normal'
    return
  fi
  # This is not a variable assignment, don't remove spaces!
  _values="${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet

# User configuration

fuzzy_commits() {
  local target
  target=$(_fzf_git_hashes)

  if [[ -z "$target" ]]; then
    return
  fi

  git switch --detach "$target"
}

fuzzy_git_branches() {
  local target
  target=$(_fzf_git_branches)

  if [[ -z "$target" ]]; then
    return
  fi

  git switch "$target"
}

alias zshconfig="nvim ~/.zshrc"
alias bat=batcat
alias ls="eza --icons"
alias d=dotnet
alias lg=lazygit
alias fgc=fuzzy_commits
alias fgb=fuzzy_git_branches

# Windows aliases
alias e="/mnt/c/Windows/explorer.exe"

export FZF_CTRL_R_OPTS="--reverse --preview 'echo {}' --preview-window down:3:hidden:wrap --bind 'ctrl-/:toggle-preview'"

# The plugin will auto execute this zvm_after_init function
# Needed for zsh-vi-mode plugin to work since it will override keybinds
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
  [ -f ~/fzf-git.sh ] && source ~/fzf-git.sh
}

setopt appendhistory

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# Added by get-aspire-cli.sh
export PATH="$HOME/.aspire/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

if [ -z "$TMUX" ]; then
  tmux attach || sesh connect Dotfiles
fi

source ~/fzf-git.sh
source <(fzf --zsh)
eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/montys_custom.omp.json --strict)"
