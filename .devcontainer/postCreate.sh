#!/usr/bin/env bash
set -euo pipefail

if [ -S "${SSH_AUTH_SOCK:-}" ]; then
  echo "SSH agent detected."
else
  echo "No SSH agent detected. Git over SSH may not work; use HTTPS or set up SSH."
fi

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
