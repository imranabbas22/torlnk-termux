#!/data/data/com.termux/files/usr/bin/bash
# torlnk-termux — Termux (Android) installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/imranabbas22/torlnk-termux/main/termux-install.sh | bash

set -e

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${CYAN}*${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
fail()  { printf "${RED}✗${NC} %s\n" "$*"; exit 1; }

printf "\n\033[1m╔══════════════════════════════════════════╗\033[0m\n"
printf "\033[1m║   torlnk-termux — Installer              ║\033[0m\n"
printf "\033[1m╚══════════════════════════════════════════╝\033[0m\n\n"

if [ -z "$TERMUX_VERSION" ] && [ ! -d /data/data/com.termux ]; then
  fail "This script is for Termux on Android."
fi

info "Updating packages..."
pkg update -y 2>/dev/null || true

info "Installing Node.js..."
if command -v node &>/dev/null; then
  ok "Node.js $(node -v) already installed"
else
  pkg install -y nodejs
  ok "Node.js $(node -v) installed"
fi

NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 22 ]; then
  warn "Node.js v22+ recommended. You have v$NODE_MAJOR."
  warn "Run: pkg upgrade nodejs"
fi

if [ ! -d /data/data/com.termux/files/home/storage ]; then
  info "Requesting storage access..."
  termux-setup-storage 2>/dev/null || warn "Skip storage setup"
else
  ok "Storage accessible"
fi

info "Installing torlnk-termux..."
# --ignore-scripts is CRITICAL on Termux:
# npm's child_process calls use /bin/sh which doesn't exist on Termux.
# Native modules (node-datachannel, utp-native) can't compile on Android
# anyway, so skipping install scripts is fine — our stubs handle them.
npm install -g --ignore-scripts github:imranabbas22/torlnk-termux 2>&1 | grep -v "tar.*warn" | grep -v "deprecated"
ok "torlnk-termux installed"

printf "\n"
printf "${GREEN}\033[1m╔══════════════════════════════════════════╗\033[0m\n"
printf "${GREEN}\033[1m║  torlnk-termux is ready!                 ║\033[0m\n"
printf "${GREEN}\033[1m╚══════════════════════════════════════════╝\033[0m\n"
printf "\n"
printf "  Run:      \033[1mtorlnk-termux\033[0m\n"
printf "  Help:     press \033[1m?\033[0m inside the app\n"
printf "  Downloads: ~/Downloads/torlink/ (press \033[1mo\033[0m to change)\n"
printf "\n"
