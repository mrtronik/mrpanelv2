#!/bin/bash
# ══════════════════════════════════════════════
#  dependency.sh — Install system dependencies
# ══════════════════════════════════════════════

banner "Step 2/8: System Dependencies"

export DEBIAN_FRONTEND=noninteractive

# ─── Update system ────────────────────────────
log "Updating system packages..."
apt-get update -qq >> "$LOG_FILE" 2>&1
apt-get upgrade -y -qq >> "$LOG_FILE" 2>&1

# ─── Essential packages ───────────────────────
log "Installing essential packages..."
PACKAGES=(
    curl wget git unzip zip software-properties-common
    build-essential gcc g++ make
    python3 python3-pip
    cron logrotate
    net-tools lsof htop tmux
    jq
)

apt-get install -y -qq ${PACKAGES[@]} >> "$LOG_FILE" 2>&1
log "Essential packages installed"

# ─── Node.js 22.x ────────────────────────────
if command -v node &>/dev/null; then
    NODE_VER=$(node --version)
    log "Node.js already installed: $NODE_VER"
else
    log "Installing Node.js 22.x..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >> "$LOG_FILE" 2>&1
    apt-get install -y -qq nodejs >> "$LOG_FILE" 2>&1
    log "Node.js installed: $(node --version)"
fi

# ─── PM2 ──────────────────────────────────────
if command -v pm2 &>/dev/null; then
    log "PM2 already installed: $(pm2 --version)"
else
    log "Installing PM2..."
    npm install -g pm2 >> "$LOG_FILE" 2>&1
    log "PM2 installed: $(pm2 --version)"
fi

# ─── WP-CLI ───────────────────────────────────
if [ -f /usr/local/bin/wp ]; then
    log "WP-CLI already installed"
else
    log "Installing WP-CLI..."
    curl -sL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp
    chmod +x /usr/local/bin/wp
    log "WP-CLI installed"
fi

# ─── Certbot ──────────────────────────────────
if command -v certbot &>/dev/null; then
    log "Certbot already installed"
else
    log "Installing Certbot..."
    apt-get install -y -qq certbot >> "$LOG_FILE" 2>&1
    log "Certbot installed"
fi

echo ""
