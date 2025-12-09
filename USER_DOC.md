# User Documentation

This document explains how to use the Inception infrastructure as an end user or administrator.

## Table of Contents
- [Services Provided](#services-provided)
- [Starting and Stopping](#starting-and-stopping)
- [Accessing the Website](#accessing-the-website)
- [Managing Credentials](#managing-credentials)
- [Checking Service Health](#checking-service-health)

## Services Provided

The Inception stack provides the following services:

### 1. **WordPress Website**
- A fully functional WordPress content management system
- Accessible via HTTPS (secure connection)
- Pre-configured with an admin user and a regular user

### 2. **NGINX Web Server**
- Serves as a reverse proxy and web server
- Handles HTTPS/TLS encryption
- Routes requests to the WordPress application

### 3. **MariaDB Database**
- Database backend for WordPress
- Stores all website content, users, and settings
- Not directly accessible from outside the container network

## Starting and Stopping

### Prerequisites
Before starting, ensure:
- Docker and Docker Compose are installed on your system
- You have the required `.env` file in the `srcs/` directory
- Your domain is configured in `/etc/hosts` (e.g., `127.0.0.1 mszymcza.42.fr`)

### Starting the Project

To start all services:

```bash
make
```

This command will:
1. Create the data directories (`~/data/wordpress` and `~/data/mariadb`)
2. Build all Docker images
3. Start all containers in detached mode

**Expected output:**
```
✔ Network inception       Created
✔ Volume wordpress_data   Created
✔ Volume mariadb_data     Created
✔ Container mariadb       Started
✔ Container wordpress     Started
✔ Container nginx         Started
```

### Stopping the Project

To stop all running containers:

```bash
make down
```

This will stop the containers but preserve your data in the volumes.

### Restarting Services

To restart all services:

```bash
make restart
```

This is equivalent to running `make down` followed by `make`.

## Accessing the Website

### WordPress Frontend

Once the services are running, access the WordPress website at:

**URL**: https://mszymcza.42.fr (or your configured domain)

**Note**: Since the project uses a self-signed SSL certificate, your browser will show a security warning. This is normal for development environments.

To bypass the warning:
- **Chrome/Edge**: Click "Advanced" → "Proceed to site"
- **Firefox**: Click "Advanced" → "Accept the Risk and Continue"
- **Safari**: Click "Show Details" → "visit this website"

### WordPress Admin Panel

To access the administration dashboard:

**URL**: https://mszymcza.42.fr/wp-admin

**Default credentials**: Use the admin credentials specified in your `.env` file:
- **Username**: Value of `WP_ADMIN_USER`
- **Password**: Value of `WP_ADMIN_PASSWORD`

From the admin panel, you can:
- Create and edit posts/pages
- Manage users
- Install themes and plugins
- Configure site settings
- View site analytics

## Managing Credentials

### Credential Storage Location

All credentials are stored in the `.env` file located at `srcs/.env`.

**⚠️ Security Warning**: Never commit the `.env` file to version control. It contains sensitive information.

### Credentials Overview

The following credentials are configured in your `.env` file:

#### Database Credentials
- `MYSQL_ROOT_PASSWORD`: MariaDB root password (administrative access)
- `MYSQL_USER`: WordPress database user
- `MYSQL_PASSWORD`: Password for the WordPress database user
- `MYSQL_DATABASE`: Database name (typically "wordpress")

#### WordPress Admin Credentials
- `WP_ADMIN_USER`: WordPress administrator username
- `WP_ADMIN_PASSWORD`: WordPress administrator password
- `WP_ADMIN_EMAIL`: WordPress administrator email

#### WordPress Regular User
- `WP_USER`: Additional WordPress user (editor/author)
- `WP_USER_PASSWORD`: Password for the additional user
- `WP_USER_EMAIL`: Email for the additional user

### Changing Credentials

To change credentials:

1. Stop the services:
   ```bash
   make down
   ```

2. Edit the `.env` file:
   ```bash
   nano srcs/.env
   ```

3. Update the desired credentials

4. Remove existing data (required for database password changes):
   ```bash
   make clean
   ```

5. Restart the services:
   ```bash
   make
   ```

**Note**: Changing database credentials requires rebuilding the database, which will delete existing data.

### Viewing Current Credentials

To view your current configuration without exposing passwords:

```bash
cat srcs/.env | grep -v PASSWORD
```

## Checking Service Health

### Verifying All Services Are Running

Check the status of all containers:

```bash
docker compose -f srcs/docker-compose.yml ps
```

**Expected output:**
```
NAME        IMAGE              STATUS         PORTS
mariadb     mariadb:custom     Up 2 minutes   3306/tcp
nginx       nginx:custom       Up 2 minutes   0.0.0.0:443->443/tcp
wordpress   wordpress:custom   Up 2 minutes   9000/tcp
```

All services should show `Up` status.

### Viewing Service Logs

To monitor logs from all services in real-time:

```bash
make logs
```

To view logs for a specific service:

```bash
# NGINX logs
docker compose -f srcs/docker-compose.yml logs nginx

# WordPress logs
docker compose -f srcs/docker-compose.yml logs wordpress

# MariaDB logs
docker compose -f srcs/docker-compose.yml logs mariadb
```

### Testing Individual Services

#### Test NGINX
```bash
curl -k https://mszymcza.42.fr
```
Should return HTML content from WordPress.

#### Test MariaDB
```bash
docker exec -it mariadb mysql -u root -p
```
Enter the root password and verify you can access the database prompt.

#### Test WordPress
```bash
docker exec -it wordpress wp --info --allow-root
```
Should display WP-CLI information, confirming WordPress is properly installed.

### Common Health Checks

#### Website is accessible
```bash
curl -k -I https://mszymcza.42.fr
```
Should return `HTTP/2 200` or `HTTP/1.1 200`.

#### Database connection
```bash
docker exec -it wordpress wp db check --allow-root
```
Should return `Success: Database connection is working.`

#### Volume data persistence
```bash
ls -la ~/data/wordpress
ls -la ~/data/mariadb
```
Should show WordPress files and MariaDB data files respectively.

### Troubleshooting

#### Service won't start
Check logs for the specific service:
```bash
docker compose -f srcs/docker-compose.yml logs <service-name>
```

#### Cannot access website
1. Verify NGINX is running: `docker ps | grep nginx`
2. Check firewall rules: `sudo lsof -i :443`
3. Verify domain in `/etc/hosts`: `cat /etc/hosts | grep mszymcza`

#### Database connection errors
1. Verify MariaDB is running: `docker ps | grep mariadb`
2. Check database logs: `docker logs mariadb`
3. Verify credentials in `.env` file

#### Containers keep restarting
```bash
docker compose -f srcs/docker-compose.yml ps
docker logs <container-name>
```
Look for error messages in the logs indicating configuration issues.

## Data Backup

Your persistent data is stored in:
- **WordPress files**: `~/data/wordpress`
- **Database files**: `~/data/mariadb`

To backup your data:

```bash
# Create backup directory
mkdir -p ~/inception-backups/$(date +%Y%m%d)

# Copy data
cp -r ~/data/wordpress ~/inception-backups/$(date +%Y%m%d)/
cp -r ~/data/mariadb ~/inception-backups/$(date +%Y%m%d)/

# Backup .env file
cp srcs/.env ~/inception-backups/$(date +%Y%m%d)/
```

To restore from backup:

```bash
make down
rm -rf ~/data/wordpress ~/data/mariadb
cp -r ~/inception-backups/YYYYMMDD/wordpress ~/data/
cp -r ~/inception-backups/YYYYMMDD/mariadb ~/data/
make
```
