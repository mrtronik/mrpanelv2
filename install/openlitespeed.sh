#!/bin/bash
# ══════════════════════════════════════════════
#  openlitespeed.sh — Install & configure OLS
# ══════════════════════════════════════════════

banner "Langkah ke 5 dari 8: Instalasi WebServer"

# ─── Install OLS ──────────────────────────────
if [ -f /usr/local/lsws/bin/lswsctrl ]; then
    sukses "WebServer sudah Aktif"
else
    proses "Menginstall WebServer..."
    apt-get install -y -qq openlitespeed >> "$LOG_FILE" 2>&1
    sukses "WebServer sudah Aktif"
fi

# ─── Start OLS ────────────────────────────────
proses "Menjalankan WebServer..."
systemctl enable lshttpd >> "$LOG_FILE" 2>&1 || true
systemctl start lshttpd >> "$LOG_FILE" 2>&1 || true
sukses "WebServer sudah Jalan"

# ─── Set admin password ───────────────────────
proses "Membuat password WebServer..."
OLS_ADMIN_PASS=$(openssl rand -hex 8)
cat > /usr/local/lsws/conf/htpasswd << EOF
mrpanel:${OLS_ADMIN_PASS}
EOF
chown lsadm:nogroup /usr/local/lsws/conf/htpasswd
sukses "WebServer Admin password: $OLS_ADMIN_PASS"

# ─── Create vhosts directory ──────────────────
mkdir -p /usr/local/lsws/conf/vhosts
chown -R lsadm:nogroup /usr/local/lsws/conf/vhosts
#log "Vhosts directory ready"

# ─── Create document roots directory ──────────
mkdir -p /home/public_html
chown -R lsadm:nogroup /home/public_html
#log "Document roots directory ready"

# ─── Create default vhost template ────────────
cat > /usr/local/lsws/conf/vhosts/Example/vhconf.conf << 'EOF'
docRoot $VH_ROOT/html/

index {
  useServer               0
  indexFiles              index.php, index.html
}

accessControl {
  deny
  allow *
}

errorlog $VH_ROOT/logs/error.log {
  logLevel                DEBUG
  rollingSize             10M
  useServer               1
}

accessLog $VH_ROOT/logs/access.log {
  compressArchive         0
  logReferer              1
  keepDays                30
  rollingSize             10M
  logUserAgent            1
  useServer               0
}

rewrite {
  enable                  1
  autoLoadHtaccess        1
}
EOF

mkdir -p /usr/local/lsws/conf/vhosts/Example/html
echo "<h1>OpenLiteSpeed is running</h1>" > /usr/local/lsws/conf/vhosts/Example/html/index.html
chown -R lsadm:nogroup /usr/local/lsws/conf/vhosts/Example
#log "Example vhost configured"

# ─── Reload OLS ───────────────────────────────
/usr/local/lsws/bin/lswsctrl reload >> "$LOG_FILE" 2>&1 || true
#log "OLS reloaded"

echo ""
