#!/bin/bash
# finish.sh - Post-install summary

banner "Step 8/8: Installation Complete!"

# ─── Verify services ──────────────────────────
log "Verifying services..."

# MySQL
if systemctl is-active --quiet mariadb; then
    log "MariaDB: Running"
else
    warn "MariaDB: Not running"
fi

# OLS
if systemctl is-active --quiet lshttpd; then
    log "OpenLiteSpeed: Running"
else
    warn "OpenLiteSpeed: Not running"
fi

# PM2
if pm2 list 2>/dev/null | grep -q "online"; then
    log "MR Panel: Running"
else
    warn "MR Panel: Not running"
fi

# ─── Save credentials ─────────────────────────
CRED_FILE="/root/mrpanel-credentials.txt"
cat > "$CRED_FILE" << EOF
============================================
  MR Panel Installation Credentials
  Generated: $(date)
============================================

MySQL Root Password:  ${MYSQL_ROOT_PASS}
OLS WebAdmin Password: ${OLS_ADMIN_PASS}
Panel App Key:        ${APP_KEY}

MR Panel URL:    http://${PUBLIC_IP}:${PANEL_PORT}
OLS WebAdmin:    http://${PUBLIC_IP}:7080

Panel Login:
  Username: admin
  Password: (set on first login)

============================================
  IMPORTANT: Save these credentials!
  File: ${CRED_FILE}
============================================
EOF

chmod 600 "$CRED_FILE"
log "Credentials saved to $CRED_FILE"

# ─── Summary ──────────────────────────────────
echo ""
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  MR Panel Installation Complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  ${CYAN}MR Panel URL:${NC}    http://${PUBLIC_IP}:${PANEL_PORT}"
echo -e "  ${CYAN}OLS WebAdmin:${NC}    http://${PUBLIC_IP}:7080"
echo ""
echo -e "  ${CYAN}MySQL Root Pass:${NC} ${MYSQL_ROOT_PASS}"
echo -e "  ${CYAN}OLS Admin Pass:${NC}  ${OLS_ADMIN_PASS}"
echo ""
echo -e "  ${CYAN}Panel Directory:${NC} /opt/mrpanel"
echo -e "  ${CYAN}Install Log:${NC}     ${LOG_FILE}"
echo -e "  ${CYAN}Credentials:${NC}     ${CRED_FILE}"
echo ""
echo -e "  ${YELLOW}Next steps:${NC}"
echo -e "  1. Open http://${PUBLIC_IP}:${PANEL_PORT}"
echo -e "  2. Create your admin account"
echo -e "  3. Add a website and install WordPress"
echo -e "  4. Point your domain DNS to ${PUBLIC_IP}"
echo ""
echo -e "${GREEN}============================================${NC}"
