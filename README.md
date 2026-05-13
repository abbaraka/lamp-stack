# LAMP Stack Server v1

A LAMP stack installer for Ubuntu 24.04 LTS, in one server

## Stack
- **Linux** - Ubuntu 24.04 LTS
- **Nginx** - Web Server
- **MySQL** - Database server
- **PHP 8.3** - Application language

## Limitations
- HTTP only
- No load balancing
- No automated back ups
- No monitoring 
- No log rotation configured
- No caching layer
**Note** - Check out v2 for increased properties

## Requirements
- Fresh Ubuntu LTS Server
- Root or sudo access
- Internet connectioon

## Your Server Details

Details to use in your .env file

### Your IP address
```bash
hostname -I
```

Use the first IP shown as your SERVER_NAME.

### Your hostname
```bash
hostname
```

### Reccomended WEB_ROOT
```bash
/var/www/your-site-name
```
Replace `your-site-name` with anything you like e.g. `/var/www/mysite`

## Installation

### Step 1 - Clone the repo
```bash
git clone https://github.com/abbaraka/lamp-stack.git
cd lamp-stack
```

### Step 2 - Configure environment
```bash
cp .env.example .env
nano .env
```

Fill in your values:
- DB_NAME - database name
- DB_USER - database username
- DB_PASSWORD - a strong password(8 characters minimum... A combination of letters, capital and small, numbers and symbols)
- SERVER_NAME - server hostname or IP
- WEB_ROOT - where to serve the files from (/var/www/your-site-name , as set in .env)

### Step 3 - Run the installer
```bash
sudo bash install.sh
```

### Step 4 - Verify installation
```bash
curl http://your-server-ip
```

## What the Installer Does
1. Updates package lists
2. Installs Nginx, PHP 8.3, MySQL
3. Configures Nginx virtual host
4. Hides Nginx and PHP version information
5. Creates database and user from .env values
6. Deploys web application
7. Configures UFW firewall (ports 22 and 80)
8. Starts and enables all services

## After Installation
Check logs:
```bash
# Nginx access log
sudo tail -f /var/log/nginx/milena-access.log

# Nginx error log
sudo tail -f /var/log/nginx/milena-error.log

# MySQL status
sudo systemctl status mysql

# PHP-FPM status
sudo systemctl status php8.3-fpm
```

## Author
A.BARAKA
GitHub: https://github.com/abbaraka
