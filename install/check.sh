#!/bin/bash
# ══════════════════════════════════════════════
#  check.sh — System checks
# ══════════════════════════════════════════════

banner "Step 1/8: System Checks"

# ─── OS check ─────────────────────────────────
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [[ "$ID" != "ubuntu" ]]; then
        err "Unsupported OS: $ID. This installer requires Ubuntu."
    fi
    log "OS: $PRETTY_NAME"
else
    err "Cannot detect OS. /etc/os-release not found."
fi

# ─── Version check ────────────────────────────
VERSION_NUM=$(echo "$VERSION_ID" | tr -d '.')
if [ "$VERSION_NUM" -lt 2204 ]; then
    err "Ubuntu 22.04+ required. Found: $VERSION_ID"
fi
log "Ubuntu version OK: $VERSION_ID"

# ─── Root check ───────────────────────────────
if [ "$EUID" -ne 0 ]; then
    err "Must run as root"
fi
log "Running as root"

# ─── Architecture ─────────────────────────────
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ] && [ "$ARCH" != "aarch64" ]; then
    err "Unsupported architecture: $ARCH"
fi
log "Architecture: $ARCH"

# ─── RAM check ────────────────────────────────
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
if [ "$TOTAL_RAM" -lt 512 ]; then
    warn "Low RAM: ${TOTAL_RAM}MB. Recommended: 1GB+"
else
    log "RAM: ${TOTAL_RAM}MB"
fi

# ─── Disk check ───────────────────────────────
DISK_FREE=$(df -BG / | awk 'NR==2{print $4}' | tr -d 'G')
if [ "$DISK_FREE" -lt 2 ]; then
    err "Insufficient disk space: ${DISK_FREE}GB free. Need 2GB+"
fi
log "Disk free: ${DISK_FREE}GB"

# ─── Existing install check ───────────────────
if [ -d /opt/mrpanel ]; then
    warn "MR Panel already installed at /opt/mrpanel"
    read -p "Reinstall? This will NOT delete data. [y/N]: " REINSTALL
    if [[ ! "$REINSTALL" =~ ^[Yy]$ ]]; then
        err "Installation cancelled."
    fi
fi

# ─── Network check ────────────────────────────
if ! ping -c 1 -W 3 8.8.8.8 &>/dev/null; then
    warn "No internet connectivity detected"
else
    log "Internet connection OK"
fi

# ─── Generate MySQL password if not set ───────
if [ -z "$MYSQL_ROOT_PASS" ]; then
    MYSQL_ROOT_PASS=$(openssl rand -hex 16)
fi
log "MySQL root password generated"

# ─── Detect public IP ─────────────────────────
PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || curl -s ipinfo.io/ip 2>/dev/null || echo "unknown")
log "Public IP: $PUBLIC_IP"

echo ""
