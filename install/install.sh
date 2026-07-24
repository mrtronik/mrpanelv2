#!/bin/bash
# ══════════════════════════════════════════════
#  MR Panel — One-Click Installer
#  Tested on: Ubuntu 22.04 / 24.04
# ══════════════════════════════════════════════

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="/tmp/mrpanel-install.log"
PANEL_PORT=3000
MYSQL_ROOT_PASS="$(openssl rand -hex 16)"
APP_KEY="mrpanel-$(cat /proc/sys/kernel/random/uuid)"
PANEL_DOMAIN=""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err() { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; exit 1; }
banner() { echo -e "\n${CYAN}═══ $1 ═══${NC}\n" | tee -a "$LOG_FILE"; }

# ─── Check root ──────────────────────────────
if [ "$EUID" -ne 0 ]; then
    err "Please run as root: sudo bash install.sh"
fi

# ─── Detect source directory ──────────────────
# If install.sh is inside the project, PROJECT_DIR is one level up
if [ -f "$SCRIPT_DIR/../package.json" ] && [ -f "$SCRIPT_DIR/../app.js" ]; then
    PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [ -f "$SCRIPT_DIR/app.js" ]; then
    PROJECT_DIR="$SCRIPT_DIR"
else
    PROJECT_DIR=""
fi

# ─── Parse args ──────────────────────────────
while [ $# -gt 0 ]; do
    case $1 in
        --domain) PANEL_DOMAIN="$2"; shift 2 ;;
        --port) PANEL_PORT="$2"; shift 2 ;;
        --password) MYSQL_ROOT_PASS="$2"; shift 2 ;;
        --src) PROJECT_DIR="$2"; shift 2 ;;
        --help)
            echo "Usage: sudo bash install.sh [options]"
            echo "  --domain    Panel domain (e.g. panel.example.com)"
            echo "  --port      Panel port (default: 3000)"
            echo "  --password  MySQL root password (default: random)"
            echo "  --src       MR Panel source directory"
            exit 0 ;;
        *) shift ;;
    esac
done

banner "MR Panel Installer v1.0"
echo "Log file: $LOG_FILE"
echo ""

# ─── Run scripts ─────────────────────────────
source "$SCRIPT_DIR/check.sh"
source "$SCRIPT_DIR/dependency.sh"
source "$SCRIPT_DIR/database.sh"
source "$SCRIPT_DIR/php.sh"
source "$SCRIPT_DIR/openlitespeed.sh"
source "$SCRIPT_DIR/mrpanel.sh"
source "$SCRIPT_DIR/firewall.sh"
source "$SCRIPT_DIR/finish.sh"
