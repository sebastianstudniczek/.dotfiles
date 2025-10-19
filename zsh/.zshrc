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

export PATH=$PATH:~/.local/bin:~/go/bin:~/.dotnet/tools:/snap/bin:/opt/nvim-linux-x86_64/bin:~/.local/share/JetBrains/Toolbox/apps/rider/bin
# export BROWSER="/mnt/c/Program\\ Files\\ (x86)/Microsoft/Edge/Application/msedge.exe"
export MESA_D3D12_DEFAULT_ADAPTER_NAME="NVIDIA"

fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
autoload -U compinit && compinit
source $ZSH/oh-my-zsh.sh

# Import local config
if [ -f ~/.zshrc.local ]; then
  source ~/.zshrc.local
fi

# Disable sound notifications
unsetopt BEEP

# Sesh
function sesh-sessions() {
  {
    #exec </dev/tty and exec <&1: These lines are a bit of a workaround often used in Zsh widgets or functions that interact with interactive tools like fzf.
    exec </dev/tty # Redirects the standard input (stdin) of the current shell to /dev/tty. This ensures that fzf receives input directly from the terminal, even if the script is run in a context where stdin might be redirected (e.g., in a script that's part of a larger pipeline).
    exec <&1       # Redirects stdin to whatever standard output (stdout) was originally connected to. This effectively restores stdin to its previous state after fzf finishes, which is important for the shell's normal operation.
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt >/dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle -N sesh-sessions                 # statemnt for allowing `sesh-sessions` function be bind to keybind
bindkey -M emacs '\es' sesh-sessions #\es -> Alt-s
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

bindkey '^H' backward-kill-word

# zsh parameter completion for the dotnet CLI
_dotnet_zsh_complete()
{
  local completions=("$(dotnet complete "$words")")
  # If the completion list is empty, just continue with filename selection
  if [ -z "$completions" ]
  then
    _arguments '*::arguments: _normal'
    return
  fi
  # This is not a variable assignment, don't remove spaces!
  _values = "${(ps:\n:)completions}"
}

compdef _dotnet_zsh_complete dotnet

# User configuration

alias zshconfig="nvim ~/.zshrc"
alias bat=batcat
alias ls="eza --icons"
alias d=dotnet
alias lg=lazygit

# Windows aliases
alias e="/mnt/c/Windows/explorer.exe"

source ~/fzf-git.sh
source ~/.fzf.zsh

setopt appendhistory

eval "$(zoxide init zsh)"
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/montys_custom.omp.json)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
