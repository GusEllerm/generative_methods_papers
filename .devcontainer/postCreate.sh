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

# Configure Powerlevel10k automatically (skip configuration wizard)
# Download a pre-built config file if .p10k.zsh doesn't exist
if [ ! -f "$HOME/.p10k.zsh" ]; then
  echo "==> Downloading Powerlevel10k configuration..."
  curl -fsSL https://raw.githubusercontent.com/romkatv/powerlevel10k/master/config/p10k-lean.zsh \
    -o "$HOME/.p10k.zsh"
fi

# Ensure .zshrc sources .p10k.zsh and disables configuration wizard
if [ -f "$HOME/.zshrc" ]; then
  # Disable configuration wizard to prevent prompts on new terminals
  # Add this before ZSH_THEME if possible
  if ! grep -q 'P10K_DISABLE_CONFIGURATION_WIZARD' "$HOME/.zshrc"; then
    # Try to add after ZSH_THEME line, otherwise append at end
    if grep -q '^ZSH_THEME=' "$HOME/.zshrc"; then
      sed -i.bak '/^ZSH_THEME=/a\
# Disable Powerlevel10k configuration wizard\
export P10K_DISABLE_CONFIGURATION_WIZARD=true
' "$HOME/.zshrc"
    else
      echo '' >> "$HOME/.zshrc"
      echo '# Disable Powerlevel10k configuration wizard' >> "$HOME/.zshrc"
      echo 'export P10K_DISABLE_CONFIGURATION_WIZARD=true' >> "$HOME/.zshrc"
    fi
  fi
  
  # Add sourcing of .p10k.zsh if not already present (oh-my-zsh template includes this)
  if ! grep -q '\[\[ ! -f ~/.p10k.zsh \]\]' "$HOME/.zshrc"; then
    cat >> "$HOME/.zshrc" << 'EOF'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF
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
sudo corepack enable
corepack prepare pnpm@latest --activate

echo "==> Installing Stencila wrapper script"
sudo install -m 755 .devcontainer/stencila-wrapper.sh /usr/local/bin/stencila-wrapper.sh
sudo ln -sf /usr/local/bin/stencila-wrapper.sh /usr/local/bin/stencila

echo "==> Versions:"
python3 --version
node --version
pnpm --version
rustc --version

echo ""
echo "==> Stencila integration ready!"
echo "   Use 'stencila' or 'stencila-wrapper.sh' to run Stencila commands"
echo "   Example: stencila --version"
