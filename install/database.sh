#!/bin/bash
# ══════════════════════════════════════════════
#  database.sh — MariaDB setup
# ══════════════════════════════════════════════

banner "Step 3/8: Database (MariaDB)"

# ─── Install MariaDB ─────────────────────────
if command -v mysql &>/dev/null; then
    log "MariaDB already installed: $(mysql --version)"
else
    log "Installing MariaDB..."
    apt-get install -y -qq mariadb-server mariadb-client >> "$LOG_FILE" 2>&1
    log "MariaDB installed: $(mysql --version)"
fi

# ─── Start & enable ───────────────────────────
systemctl enable mariadb >> "$LOG_FILE" 2>&1
systemctl start mariadb >> "$LOG_FILE" 2>&1
log "MariaDB service started"

# ─── Set root password ────────────────────────
log "Configuring MariaDB root password..."
mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASS}'; FLUSH PRIVILEGES;" >> "$LOG_FILE" 2>&1 || \
mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${MYSQL_ROOT_PASS}'); FLUSH PRIVILEGES;" >> "$LOG_FILE" 2>&1 || \
warn "Could not set root password (may already be set)"

# ─── Create .my.cnf for root ─────────────────
cat > /root/.my.cnf << EOF
[client]
user=root
password=${MYSQL_ROOT_PASS}
EOF
chmod 600 /root/.my.cnf
log "MySQL credentials saved to /root/.my.cnf"

# ─── Secure installation ──────────────────────
mysql -u root -p"${MYSQL_ROOT_PASS}" -e "
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DROP DATABASE IF EXISTS test;
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
    FLUSH PRIVILEGES;
" >> "$LOG_FILE" 2>&1 || warn "Some secure steps skipped"
log "MariaDB secured"

# ─── Create MR Panel database ─────────────────
log "Creating MR Panel database..."
mysql -u root -p"${MYSQL_ROOT_PASS}" -e "
    CREATE DATABASE IF NOT EXISTS belajar_node CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    FLUSH PRIVILEGES;
" >> "$LOG_FILE" 2>&1
log "Database 'belajar_node' created"

# ─── Bind to 127.0.0.1 only ──────────────────
if ! grep -q "bind-address.*127.0.0.1" /etc/mysql/mariadb.conf.d/50-server.cnf 2>/dev/null; then
    sed -i 's/^bind-address\s*=.*/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf 2>/dev/null || true
    systemctl restart mariadb >> "$LOG_FILE" 2>&1
    log "MariaDB bound to 127.0.0.1"
fi

echo ""
