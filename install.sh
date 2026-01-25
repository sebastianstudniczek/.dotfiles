#!/usr/bin/env bash
set -r

REPO="https://github.com/SebastianStudniczek/dotfiles.git"
TARGET="$HOME/.dotfiles"

echo 'Checking if git is installed..'

# ------------------------
# Install git if missing
# ------------------------
if ! command -v git >/dev/null; then
  echo 'Git not found. Installing git...'
  if [ -f /etc/debian_version ]; then
    sudo apt update
    sudo apt install -y git
  else
    sudo dnf install -y git
  fi
fi

echo 'Fetching dotfiles...'

# ------------------------
# Clone dotfiles
# ------------------------
if [ ! -d "$TARGET" ]; then
  git clone "$REPO" "$TARGET"
else
  cd "$TARGET"
  git pull
fi

echo 'Installing packages...'

# ncurser - for some reason $(clear) command is not included in the base image
if [ "$DISTRO" = "fedora" ]; then
  sudo dnf install -y \
    ncurses \
    neovim \
    golang \
    tmux \
    fzf \
    ripgrep \
    zsh \
    stow \
    bat.x86_64 \
    zoxide.x86_64 \
    btop.x86_64 \
    glow
fi

# ------------------------
# Set Zsh as default shell
# ------------------------
if [ "$SHELL" != "$(which zsh)" ]; then
  echo "Setting zsh as default shell"
  chsh -s "$(which zsh)"
fi

# ------------------------
# Install Oh My Zsh
# ------------------------
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh"
  RUNZSH=no CHSH=no sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# ------------------------
# Plugins
# ------------------------
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ------------------------
# Stow dotfiles
# ------------------------
cd "$(dirname "$0")/../stow"

stow zsh nvim tmux git
echo "Zsh + dotfiles installed. Log out and back in to start using zsh."
