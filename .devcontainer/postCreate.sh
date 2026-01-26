#!/usr/bin/env bash
set -euo pipefail

echo "==> Updating apt + installing base packages"
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  git curl ca-certificates \
  python3 python3-pip python3-venv pipx \
  build-essential pkg-config \
  openssh-client

echo "==> Installing Node.js 22 (via NodeSource)"
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "==> Enabling Corepack + pnpm"
# Corepack manages package managers like pnpm
corepack enable
corepack prepare pnpm@latest --activate

echo "==> pipx path"
python3 -m pip install --upgrade pip
python3 -m pip install --user pipx || true
python3 -m pipx ensurepath || true

echo "==> Done. Versions:"
python3 --version
node --version
pnpm --version
rustc --version || true
cargo --version || true
