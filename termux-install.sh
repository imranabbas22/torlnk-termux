#!/data/data/com.termux/files/usr/bin/bash
# torlnk-termux — Termux (Android) installer
# Installs Node.js and torlnk-termux globally.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/imranabbas22/torlnk-termux/main/termux-install.sh | bash

set -e

# ── helpers ──────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

info()  { printf "${CYAN}*${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
fail()  { printf "${RED}✗${NC} %s\n" "$*"; exit 1; }

header() {
  printf "\n\033[1m╔══════════════════════════════════════════╗\033[0m\n"
  printf "\033[1m║   torlnk-termux — Installer              ║\033[0m\n"
  printf "\033[1m╚══════════════════════════════════════════╝\033[0m\n\n"
}

# ── detect Termux ────────────────────────────────────────────────────────
if [ -z "$TERMUX_VERSION" ] && [ ! -d /data/data/com.termux ]; then
  fail "This script is for Termux on Android. You don't appear to be running it."
fi

header

# ── 1. Update packages ──────────────────────────────────────────────────
info "Updating package lists..."
pkg update -y 2>/dev/null || true

# ── 2. Install Node.js ──────────────────────────────────────────────────
info "Installing Node.js..."
if command -v node &>/dev/null; then
  ok "Node.js $(node -v) already installed"
else
  pkg install -y nodejs
  ok "Node.js $(node -v) installed"
fi

NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "$NODE_MAJOR" -lt 22 ]; then
  warn "Node.js v22+ is recommended. You have v$NODE_MAJOR."
  warn "Run 'pkg upgrade nodejs' to get the latest version."
fi

# ── 3. Storage permission (optional) ────────────────────────────────────
if [ -d /data/data/com.termux/files/home/storage ]; then
  ok "Storage already accessible"
else
  info "Requesting storage access..."
  termux-setup-storage 2>/dev/null || warn "Skip storage setup (not critical)"
fi

# ── 4. Install torlnk-termux globally ────────────────────────────────────
info "Installing torlnk-termux globally via npm..."
npm install -g github:imranabbas22/torlnk-termux && {
  ok "torlnk-termux installed"
} || {
  warn "Install failed. Trying with --ignore-scripts..."
  npm install -g --ignore-scripts github:imranabbas22/torlnk-termux && {
    ok "torlnk-termux installed (--ignore-scripts)"
  } || {
    fail "Could not install torlnk-termux. Check your internet connection."
  }
}

# ── 5. WebRTC note ──────────────────────────────────────────────────────
printf "\n"
info "WebRTC on Termux: native module rarely compiles — this is normal."
info "torlnk-termux falls back to TCP/uTP and DHT automatically."
printf "\n"

# ── 6. Verify ───────────────────────────────────────────────────────────
if command -v torlnk-termux &>/dev/null; then
  printf "\n"
  printf "${GREEN}\033[1m╔══════════════════════════════════════════╗\033[0m\n"
  printf "${GREEN}\033[1m║  torlnk-termux is ready!                 ║\033[0m\n"
  printf "${GREEN}\033[1m╚══════════════════════════════════════════╝\033[0m\n"
  printf "\n"
  printf "  Just run:  \033[1mtorlnk-termux\033[0m\n"
  printf "\n"
  printf "  Downloads save to:  ~/Downloads/torlink/\n"
  printf "  Press \033[1m?\033[0m inside torlnk-termux for help.\n"
  printf "\n"
else
  warn "torlnk-termux not found on PATH — try starting a new Termux session."
fi
