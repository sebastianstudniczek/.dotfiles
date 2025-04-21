# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab)

export PATH=$PATH:~/.local/bin:~/go/bin:~/.dotnet/tools
export BROWSER="/mnt/c/Program\\ Files\\ (x86)/Microsoft/Edge/Application/msedge.exe"

source $ZSH/oh-my-zsh.sh

# User configuration

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
alias bat=batcat
alias ls="eza --icons"
alias d=dotnet

# Windows aliases
alias e="/mnt/c/Windows/explorer.exe"
# $USERPROFILE variable comes from windows $WSLENV:USERPROFILE
alias rd="$USERPROFILE/AppData/Local/Programs/Rider/bin/rider64.exe"

source ~/fzf-git.sh
source ~/.fzf.zsh

eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/montys_custom.omp.json)"
