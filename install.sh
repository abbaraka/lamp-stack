#!/usr/bin/env bash
# =============================================================================
# LAMP Stack Installer - v1.0
# Tested on: Ubuntu 24.04 LTS
# Author: A.BARAKA
# GitHub: https://github.com/abbaraka/lamp-stack
#
# LIMITATIONS (v1):
# - HTTP only (no HTTPS)
# - Single server (no load balancing)
# - No automated backups
# - No monitoring
# =============================================================================

set -euo pipefail

# Colours for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No colour

# Logging functions
log()     { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*"; exit 1; }

# =============================================================================
# CHECK REQUIREMENTS
# =============================================================================

log "Checking requirements..."

# Must be run as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use: sudo bash install.sh"
fi

# Must be Ubuntu
if ! grep -q "Ubuntu" /etc/os-release; then
    warn "This script was tested on Ubuntu 24.04. Other distros may not work."
fi

# Check .env file exists
if [[ ! -f .env ]]; then
    error ".env file not found. Copy .env.example to .env and fill in your values."
fi

# Load environment variables
source .env
log "Environment variables loaded."

# =============================================================================
# INSTALL PACKAGES
# =============================================================================

log "Upgrading system..."
apt upgrade

log "Updating package lists..."
apt update -q

log "Installing Nginx..."
apt install -y nginx

log "Installing PHP and extensions..."
apt install -y php-fpm php-mysql php-cli

log "Installing MySQL..."
apt install -y mysql-server

# =============================================================================
# CONFIGURE NGINX
# =============================================================================

log "Configuring Nginx..."

# Copy virtual host config
cp config/nginx-milena.conf /etc/nginx/sites-available/milena

# Replace placeholders with values from .env
sed -i "s|<your_server_name>|$SERVER_NAME|g" /etc/nginx/sites-available/milena
sed -i "s|<your_web_root>|$WEB_ROOT|g" /etc/nginx/sites-available/milena

# Enable site
ln -sf /etc/nginx/sites-available/milena /etc/nginx/sites-enabled/

# Disable default site
rm -f /etc/nginx/sites-enabled/default

# Hide Nginx version
sed -i 's/# server_tokens off;/server_tokens off;/' /etc/nginx/nginx.conf

# Test config
nginx -t || error "Nginx configuration test failed."

# =============================================================================
# CONFIGURE PHP
# =============================================================================

log "Configuring PHP..."

# Get PHP version
PHP_VERSION=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;')
log "Detected PHP version: $PHP_VERSION"

# Hide PHP version
sed -i 's/expose_php = On/expose_php = Off/' /etc/php/$PHP_VERSION/fpm/php.ini

# Update Nginx config with correct PHP version
sed -i "s|php8.3-fpm|php$PHP_VERSION-fpm|g" /etc/nginx/sites-available/milena

# =============================================================================
# CONFIGURE MYSQL
# =============================================================================

log "Configuring MySQL..."

# Create database and user
mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS $DB_NAME;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;

USE $DB_NAME;
CREATE TABLE IF NOT EXISTS visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    visit_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO visitors (name) VALUES ('Alex'), ('Ben'), ('Carmen');
EOF

log "Database configured successfully."

# =============================================================================
# DEPLOY WEB APPLICATION
# =============================================================================

log "Deploying web application..."

# Create web root
mkdir -p $WEB_ROOT

# Copy application files
cp www/index.php $WEB_ROOT/

# Create .env in web root parent for PHP to read
cp .env $(dirname $WEB_ROOT)/.env

# Set correct permissions
chown -R www-data:www-data $WEB_ROOT
chmod -R 755 $WEB_ROOT

# =============================================================================
# CONFIGURE FIREWALL
# =============================================================================

log "Configuring firewall..."
ufw allow 22/tcp
ufw allow 80/tcp
ufw --force enable

# =============================================================================
# START SERVICES
# =============================================================================

log "Starting services..."
systemctl enable nginx
systemctl enable mysql
systemctl enable php$PHP_VERSION-fpm

systemctl restart nginx
systemctl restart mysql
systemctl restart php$PHP_VERSION-fpm

# =============================================================================
# DONE
# =============================================================================

echo ""
echo -e "${GREEN}=============================================${NC}"
echo -e "${GREEN} LAMP Stack v1 installed successfully!${NC}"
echo -e "${GREEN}=============================================${NC}"
echo ""
echo -e "Website: ${YELLOW}http://$SERVER_NAME${NC}"
echo ""
echo -e "${YELLOW}LIMITATIONS (v1):${NC}"
echo "  - HTTP only (no HTTPS) - coming in v2"
echo "  - Single server setup - coming in v2"
echo "  - No automated backups - coming in v2"
echo "  - No monitoring - coming in v2"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Visit your website to confirm it's working"
echo "  2. Check logs: tail -f /var/log/nginx/milena-access.log"
echo "  3. Check MySQL: mysql -u $DB_USER -p $DB_NAME"
echo ""
