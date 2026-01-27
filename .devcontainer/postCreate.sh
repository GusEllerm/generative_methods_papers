#!/usr/bin/env bash
set -euo pipefail

################# General setup for my dev containers #################

## Check if SSH agent is running
if [ -S "${SSH_AUTH_SOCK:-}" ]; then
  echo "SSH agent detected."
else
  echo "No SSH agent detected. Git over SSH may not work; use HTTPS or set up SSH."
fi

if ! command -v zsh >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y zsh git curl
fi

# Install Oh My Zsh (non-interactive)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install Powerlevel10k theme
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# Ensure .zshrc uses p10k
if [ -f "$HOME/.zshrc" ]; then
  if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
    sed -i.bak 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
  else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
  fi
fi

######################### Project specific setup #########################

echo "==> Installing Python tooling"
sudo apt-get update
sudo apt-get install -y \
  python3 python3-pip python3-venv pipx

echo "==> Installing Node.js 22"
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "==> Enable Corepack + pnpm"
corepack enable
corepack prepare pnpm@latest --activate

echo "==> Versions:"
python3 --version
node --version
pnpm --version
rustc --version
