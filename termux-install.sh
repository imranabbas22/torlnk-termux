#!/data/data/com.termux/files/usr/bin/bash
# torlink — Termux (Android) one-command installer
# Installs Node.js, makes storage accessible, and sets up torlink.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/imranabbas22/torlnk-termux/main/termux-install.sh | bash
#
# Or after cloning:
#   bash termux-install.sh

set -e

# ── helpers ──────────────────────────────────────────────────────────────
BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info()  { printf "${CYAN}*${NC} %s\n" "$*"; }
ok()    { printf "${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "${YELLOW}⚠${NC} %s\n" "$*"; }
fail()  { printf "${RED}✗${NC} %s\n" "$*"; exit 1; }

header() {
  printf "\n${BOLD}╔══════════════════════════════════════════╗${NC}\n"
  printf "${BOLD}║      torlink — Termux Installer          ║${NC}\n"
  printf "${BOLD}╚══════════════════════════════════════════╝${NC}\n\n"
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
  CURRENT_NODE=$(node -v)
  ok "Node.js $CURRENT_NODE already installed"
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
  info "Requesting storage access (for downloading to shared storage)..."
  termux-setup-storage 2>/dev/null || warn "Skip storage setup (not critical)"
fi

# ── 4. Install torlink ──────────────────────────────────────────────────
info "Installing torlink globally via npm..."
npm install -g torlnk 2>/dev/null && {
  ok "torlink installed from npm registry"
} || {
  warn "torlink not yet on npm registry under this fork."
  warn "Installing from GitHub instead..."
  npm install -g github:imranabbas22/torlnk-termux 2>/dev/null && {
    ok "torlink installed from GitHub"
  } || {
    warn "GitHub install failed. Trying local install..."
    cd "$(dirname "$0")" 2>/dev/null || cd ~
    if [ -f package.json ]; then
      npm install -g . && ok "torlink installed from local source"
    else
      fail "Could not install torlink. Try: npm install -g torlnk"
    fi
  }
}

# ── 5. WebRTC note ──────────────────────────────────────────────────────
printf "\n"
info "${BOLD}WebRTC on Termux${NC}"
info "The WebRTC native module (node-datachannel) rarely compiles on Android."
info "This is fine — torlink falls back to TCP/uTP and DHT seamlessly."
info "Downloads work; you just won't connect to WebRTC-only peers."
printf "\n"

# ── 6. Verify ───────────────────────────────────────────────────────────
if command -v torlnk &>/dev/null; then
  printf "\n"
  printf "${GREEN}${BOLD}╔══════════════════════════════════════════╗${NC}\n"
  printf "${GREEN}${BOLD}║  torlink is ready!                       ║${NC}\n"
  printf "${GREEN}${BOLD}╚══════════════════════════════════════════╝${NC}\n"
  printf "\n"
  printf "  Just run:  ${BOLD}torlnk${NC}\n"
  printf "\n"
  printf "  Downloads save to:  ~/Downloads/torlink/\n"
  printf "\n"
  printf "  To change the download folder, press ${BOLD}o${NC} inside torlink.\n"
  printf "  To browse shared storage:  ${BOLD}o${NC} → enter ${YELLOW}~/storage/downloads/torlink${NC}\n"
  printf "\n"
  printf "  First time? Press ${BOLD}?${NC} inside torlink for help.\n"
  printf "\n"
else
  warn "torlnk not found on PATH — try starting a new Termux session."
  warn "Or run:  npx torlnk"
fi
