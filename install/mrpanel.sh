#!/bin/bash
# mrpanel.sh - Install MR Panel application

banner "Step 6/8: MR Panel"

PANEL_DIR="/opt/mrpanel"

# Copy from source or use existing
if [ -n "$PROJECT_DIR" ] && [ -d "$PROJECT_DIR" ]; then
    log "Copying MR Panel from $PROJECT_DIR ..."
    mkdir -p "$PANEL_DIR"
    # Copy everything except node_modules and .git
    rsync -a --exclude='node_modules' --exclude='.git' --exclude='.env' "$PROJECT_DIR/" "$PANEL_DIR/"
    log "Files copied to $PANEL_DIR"
elif [ -d "$PANEL_DIR" ]; then
    log "MR Panel already at $PANEL_DIR"
else
    err "No source directory found. Use --src /path/to/project or copy files to $PANEL_DIR"
fi

cd "$PANEL_DIR"

# Install npm dependencies
log "Installing npm dependencies..."
npm install --production >> "$LOG_FILE" 2>&1
log "Dependencies installed"

# Create .env
if [ ! -f .env ]; then
    log "Creating .env configuration..."

    DB_PASSWORD="${MYSQL_ROOT_PASS}"
    PUBLIC_IP="${PUBLIC_IP:-localhost}"

    cat > .env << ENVEOF
APP_NAME=MR Panel
APP_ENV=local
APP_KEY=${APP_KEY}
APP_URL=http://${PUBLIC_IP}:${PANEL_PORT}
SESSION_LIFETIME=1440
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=${DB_PASSWORD}
DB_DATABASE=belajar_node
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=
SMTP_PASS=
SMTP_SECURE=false
ENVEOF

    chmod 600 .env
    log ".env created"
fi

# Run database migrations
log "Running database migrations..."
node database/migrate.js >> "$LOG_FILE" 2>&1 || warn "Users migration may have failed"
node database/migrate-websites.js >> "$LOG_FILE" 2>&1 || warn "Websites migration may have failed"
node database/migrate-session.js >> "$LOG_FILE" 2>&1 || warn "Session migration may have failed"
node database/migrate-email-accounts.js >> "$LOG_FILE" 2>&1 || warn "Email accounts migration may have failed"
node database/migrate-cache.js >> "$LOG_FILE" 2>&1 || warn "Cache migration may have failed"
log "Migrations completed"

# Create plugins directory
mkdir -p "$PANEL_DIR/plugins"
log "Plugins directory ready"

# Setup PM2
log "Configuring PM2..."
pm2 delete mrpanel >> "$LOG_FILE" 2>&1 || true
cd "$PANEL_DIR"
pm2 start app.js --name mrpanel --max-memory-restart 256M >> "$LOG_FILE" 2>&1
pm2 save >> "$LOG_FILE" 2>&1
log "PM2 configured and started"

# Setup PM2 startup
pm2 startup systemd -u root --hp /root >> "$LOG_FILE" 2>&1 || true
pm2 save >> "$LOG_FILE" 2>&1

# Set permissions
chown -R lsadm:nogroup "$PANEL_DIR/plugins" 2>/dev/null || true

log "MR Panel installed at $PANEL_DIR"
echo ""
