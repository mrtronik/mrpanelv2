#!/bin/bash
# firewall.sh - Configure UFW firewall

banner "Step 7/8: Firewall (UFW)"

# Install UFW if not present
if ! command -v ufw &>/dev/null; then
    log "Installing UFW..."
    apt-get install -y -qq ufw >> "$LOG_FILE" 2>&1
fi

# Reset to defaults
ufw --force reset >> "$LOG_FILE" 2>&1

# Default policies
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1

# Allow SSH
ufw allow 22/tcp >> "$LOG_FILE" 2>&1
log "Port 22 (SSH) allowed"

# Allow HTTP
ufw allow 80/tcp >> "$LOG_FILE" 2>&1
log "Port 80 (HTTP) allowed"

# Allow HTTPS
ufw allow 443/tcp >> "$LOG_FILE" 2>&1
log "Port 443 (HTTPS) allowed"

# Allow OLS WebAdmin (restrict to localhost for security)
ufw allow from 127.0.0.1 to any port 7080 >> "$LOG_FILE" 2>&1
log "Port 7080 (OLS Admin) allowed from localhost only"

# Allow MR Panel port
ufw allow ${PANEL_PORT}/tcp >> "$LOG_FILE" 2>&1
log "Port ${PANEL_PORT} (MR Panel) allowed"

# Enable UFW
ufw --force enable >> "$LOG_FILE" 2>&1
log "UFW enabled"

ufw status verbose >> "$LOG_FILE" 2>&1
echo ""
