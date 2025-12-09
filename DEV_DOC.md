# Developer Documentation

This document provides technical information for developers working on the Inception project.

## Table of Contents
- [Environment Setup](#environment-setup)
- [Build and Launch](#build-and-launch)
- [Container Management](#container-management)
- [Volume Management](#volume-management)
- [Data Persistence](#data-persistence)
- [Project Structure](#project-structure)
- [Development Workflow](#development-workflow)

## Environment Setup

### Prerequisites

Install the following software:
- **Docker**: Version 20.10 or higher
- **Docker Compose**: Version 2.0 or higher (comes with Docker Desktop)
- **Make**: Should be pre-installed on macOS/Linux
- **Text editor**: VS Code, vim, or your preferred editor

### Installation Verification

```bash
# Check Docker
docker --version
docker compose version

# Check Make
make --version
```

### Setting Up from Scratch

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd inception
   ```

2. **Create the environment file**:
   ```bash
   touch srcs/.env
   ```

3. **Configure the `.env` file**:

   Edit `srcs/.env` and add the following variables:

   ```bash
   # Domain Configuration
   DOMAIN_NAME=mszymcza.42.fr
   
   # MariaDB Configuration
   MYSQL_ROOT_PASSWORD=secure_root_password_here
   MYSQL_DATABASE=wordpress
   MYSQL_USER=wpuser
   MYSQL_PASSWORD=secure_wp_password_here
   
   # WordPress Admin
   WP_ADMIN_USER=admin
   WP_ADMIN_PASSWORD=secure_admin_password_here
   WP_ADMIN_EMAIL=admin@example.com
   
   # WordPress Additional User
   WP_USER=editor
   WP_USER_EMAIL=editor@example.com
   WP_USER_PASSWORD=secure_user_password_here
   
   # WordPress Site Configuration
   WP_TITLE="Inception WordPress"
   WP_URL=https://mszymcza.42.fr
   ```

   **Security Notes**:
   - Use strong, unique passwords
   - Never commit `.env` to version control
   - Add `.env` to `.gitignore`

4. **Configure domain resolution**:
   ```bash
   echo "127.0.0.1 mszymcza.42.fr" | sudo tee -a /etc/hosts
   ```

5. **Verify directory structure**:
   ```bash
   tree -L 3 srcs/
   ```

   Expected structure:
   ```
   srcs/
   ├── docker-compose.yml
   ├── .env
   └── requirements/
       ├── mariadb/
       │   ├── Dockerfile
       │   ├── entrypoint.sh
       │   └── my.cnf
       ├── nginx/
       │   ├── Dockerfile
       │   └── default.conf
       └── wordpress/
           ├── Dockerfile
           ├── entrypoint.sh
           └── www.conf
   ```

## Build and Launch

### Using the Makefile

The Makefile provides convenient commands for managing the project.

#### Build and Start

```bash
make
# or
make all
```

**What it does**:
1. Creates `~/data/wordpress` and `~/data/mariadb` directories
2. Builds Docker images for all services
3. Starts containers in detached mode

**Build process**:
- NGINX: Installs nginx, openssl, generates self-signed certificate
- MariaDB: Installs mariadb-server, copies configuration and entrypoint
- WordPress: Installs PHP-FPM, WordPress CLI, downloads WordPress

#### Stop Containers

```bash
make down
```

**What it does**:
- Stops all running containers
- Removes containers (but preserves volumes and images)

#### Restart

```bash
make restart
```

**What it does**:
- Runs `make down` followed by `make all`
- Useful for applying configuration changes

#### View Logs

```bash
make logs
```

**What it does**:
- Shows real-time logs from all containers
- Use `Ctrl+C` to exit

#### Clean Data

```bash
make clean
```

**What it does**:
- Runs `make down`
- Deletes `~/data/wordpress` and `~/data/mariadb`
- **Warning**: This deletes all WordPress content and database data

#### Full System Prune

```bash
make prune
# or
make fclean
```

**What it does**:
- Runs `make clean`
- Removes all stopped containers
- Removes all unused images
- Removes all unused volumes
- Removes all unused networks
- **Warning**: This is a complete cleanup and affects all Docker resources

#### Rebuild Everything

```bash
make re
```

**What it does**:
- Runs `make fclean` followed by `make all`
- Complete rebuild from scratch

### Using Docker Compose Directly

For more control, use Docker Compose commands directly:

#### Build Images

```bash
docker compose -f srcs/docker-compose.yml build
```

Options:
- `--no-cache`: Build without using cache
- `--pull`: Always pull base images
- `<service>`: Build specific service only

#### Start Services

```bash
docker compose -f srcs/docker-compose.yml up -d
```

Options:
- `-d`: Detached mode (background)
- `--build`: Build before starting
- `--force-recreate`: Recreate containers even if config hasn't changed

#### Stop Services

```bash
docker compose -f srcs/docker-compose.yml down
```

Options:
- `-v`: Also remove volumes
- `--rmi all`: Remove images
- `--remove-orphans`: Remove containers for services not in compose file

## Container Management

### Listing Containers

```bash
# All containers in the project
docker compose -f srcs/docker-compose.yml ps

# All running Docker containers
docker ps

# All containers (including stopped)
docker ps -a
```

### Inspecting Containers

```bash
# View container details
docker inspect <container_name>

# View container logs
docker logs <container_name>
docker logs -f <container_name>  # Follow mode

# View container stats
docker stats <container_name>
```

### Executing Commands in Containers

```bash
# Interactive shell
docker exec -it nginx /bin/bash
docker exec -it mariadb /bin/bash
docker exec -it wordpress /bin/bash

# Single command
docker exec nginx ls -la /etc/nginx
docker exec mariadb mysql -u root -p
docker exec wordpress wp --info --allow-root
```

### Debugging Containers

#### Check container logs

```bash
# All services
docker compose -f srcs/docker-compose.yml logs

# Specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs -f wordpress  # Follow mode
```

#### Inspect running processes

```bash
docker exec nginx ps aux
docker top nginx
```

#### Check network connectivity

```bash
# From WordPress to MariaDB
docker exec wordpress ping mariadb

# From WordPress to NGINX
docker exec wordpress ping nginx

# Check DNS resolution
docker exec wordpress nslookup mariadb
```

#### View environment variables

```bash
docker exec nginx env
docker exec wordpress env | grep MYSQL
```

## Volume Management

### Understanding Volume Configuration

The project uses bind mounts configured as Docker volumes in `docker-compose.yml`:

```yaml
volumes:
  wordpress_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/wordpress
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: ~/data/mariadb
```

### Listing Volumes

```bash
# Docker volumes
docker volume ls

# Project volumes specifically
docker volume ls | grep inception
```

### Inspecting Volumes

```bash
docker volume inspect inception_wordpress_data
docker volume inspect inception_mariadb_data
```

### Accessing Volume Data

The data is directly accessible on the host:

```bash
# WordPress files
ls -la ~/data/wordpress

# MariaDB data files
ls -la ~/data/mariadb
```

### Volume Operations

#### Manual backup

```bash
# Backup WordPress
tar -czf wordpress_backup_$(date +%Y%m%d).tar.gz -C ~/data wordpress

# Backup MariaDB
tar -czf mariadb_backup_$(date +%Y%m%d).tar.gz -C ~/data mariadb
```

#### Manual restore

```bash
# Stop services first
make down

# Restore WordPress
rm -rf ~/data/wordpress
tar -xzf wordpress_backup_YYYYMMDD.tar.gz -C ~/data

# Restore MariaDB
rm -rf ~/data/mariadb
tar -xzf mariadb_backup_YYYYMMDD.tar.gz -C ~/data

# Restart services
make
```

#### Clear volume data

```bash
# Using Makefile
make clean

# Manually
sudo rm -rf ~/data/wordpress ~/data/mariadb
```

## Data Persistence

### Where Data is Stored

#### WordPress Data (`~/data/wordpress`)
- **WordPress core files**: wp-admin, wp-includes, wp-content
- **Themes**: wp-content/themes/
- **Plugins**: wp-content/plugins/
- **Uploads**: wp-content/uploads/
- **Configuration**: wp-config.php

#### MariaDB Data (`~/data/mariadb`)
- **Database files**: .frm, .ibd files
- **System tables**: mysql/, performance_schema/
- **WordPress database**: wordpress/
- **Logs**: Binary logs, error logs

### How Persistence Works

1. **Container lifecycle**:
   - When containers are created, they mount the host directories
   - Data written by the container is immediately visible on the host
   - When containers are destroyed, data remains on the host

2. **Data flow**:
   ```
   Container Write → Bind Mount → Host Filesystem
   ```

3. **Permissions**:
   - WordPress container runs as www-data (UID 33)
   - MariaDB container runs as mysql (UID 999)
   - Files created in volumes have these ownership settings

### Verifying Persistence

```bash
# Create test content in WordPress
docker exec wordpress wp post create \
  --post_title="Test Post" \
  --post_content="Testing persistence" \
  --post_status=publish \
  --allow-root

# Restart containers
make restart

# Verify data persists
docker exec wordpress wp post list --allow-root
```

### Database Persistence

The MariaDB entrypoint script initializes the database only if `/var/lib/mysql` is empty:

```bash
# Check if database is initialized
ls -la ~/data/mariadb/

# If initialized, you'll see:
# - mysql/ directory
# - wordpress/ directory  
# - ib_logfile*, ibdata* files
```

## Project Structure

### Directory Layout

```
inception/
├── Makefile                          # Build automation
├── README.md                         # Project documentation
├── USER_DOC.md                       # User guide
├── DEV_DOC.md                        # Developer guide (this file)
└── srcs/
    ├── .env                          # Environment variables (not in git)
    ├── docker-compose.yml            # Service orchestration
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile            # MariaDB image definition
        │   ├── entrypoint.sh         # Database initialization script
        │   └── my.cnf                # MariaDB configuration
        ├── nginx/
        │   ├── Dockerfile            # NGINX image definition
        │   └── default.conf          # NGINX server configuration
        └── wordpress/
            ├── Dockerfile            # WordPress image definition
            ├── entrypoint.sh         # WordPress initialization script
            └── www.conf              # PHP-FPM pool configuration
```

### Service Architecture

```
┌─────────────────────────────────────────────────────────┐
│                        Host System                       │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Docker Network (inception)            │ │
│  │                                                    │ │
│  │  ┌──────────┐    ┌──────────┐    ┌──────────┐   │ │
│  │  │  NGINX   │───▶│WordPress │───▶│ MariaDB  │   │ │
│  │  │  :443    │    │   :9000  │    │  :3306   │   │ │
│  │  └──────────┘    └──────────┘    └──────────┘   │ │
│  │       │                │                │        │ │
│  └───────┼────────────────┼────────────────┼────────┘ │
│          │                │                │          │
│          ▼                ▼                ▼          │
│   ~/data/wordpress   ~/data/wordpress  ~/data/mariadb │
└─────────────────────────────────────────────────────────┘
```

### Configuration Files

#### `docker-compose.yml`
- Defines three services: nginx, wordpress, mariadb
- Configures network (bridge driver)
- Defines volumes (bind mounts)
- Sets dependencies (mariadb ← wordpress ← nginx)

#### `Makefile`
- Automates common tasks
- Manages volume directories
- Provides convenient aliases for Docker commands

#### Service Dockerfiles
Each Dockerfile:
- Uses `debian:bookworm` as base
- Installs required packages
- Copies configuration files
- Sets up entrypoints and commands

## Development Workflow

### Making Changes

#### 1. Modify Configuration Files

After changing nginx, php-fpm, or database configuration:

```bash
make restart
```

#### 2. Modify Dockerfiles

After changing Dockerfile or dependencies:

```bash
# Rebuild specific service
docker compose -f srcs/docker-compose.yml build nginx
docker compose -f srcs/docker-compose.yml up -d nginx

# Or rebuild everything
make re
```

#### 3. Modify Entrypoint Scripts

After changing `entrypoint.sh`:

```bash
# Rebuild and restart
docker compose -f srcs/docker-compose.yml build <service>
make clean  # Clear data if entrypoint initializes database
make
```

### Testing Changes

#### Run health checks

```bash
# NGINX config test
docker exec nginx nginx -t

# WordPress CLI
docker exec wordpress wp --info --allow-root

# Database connection
docker exec wordpress wp db check --allow-root
```

#### Validate Docker Compose

```bash
docker compose -f srcs/docker-compose.yml config
```

#### Check for errors

```bash
# View recent logs
docker compose -f srcs/docker-compose.yml logs --tail=50

# Monitor logs in real-time
make logs
```

### Debugging Tips

#### Container won't start
1. Check logs: `docker logs <container>`
2. Verify Dockerfile syntax
3. Test entrypoint script manually:
   ```bash
   docker run -it --rm <image> /bin/bash
   sh /path/to/entrypoint.sh
   ```

#### Network connectivity issues
```bash
# List networks
docker network ls

# Inspect network
docker network inspect inception_inception

# Test connectivity
docker exec wordpress ping mariadb
```

#### Permission issues
```bash
# Check file ownership
ls -la ~/data/wordpress
ls -la ~/data/mariadb

# Fix permissions (if needed)
sudo chown -R $(whoami):$(whoami) ~/data
```

#### Database initialization fails
```bash
# Clear data and reinitialize
make clean
make

# Check entrypoint logs
docker logs mariadb
```

### Best Practices

1. **Always test changes locally** before committing
2. **Use `make re`** for major changes to ensure clean state
3. **Check logs** after every change
4. **Backup data** before destructive operations
5. **Keep `.env` secure** and never commit it
6. **Document changes** in commit messages
7. **Use meaningful variable names** in scripts
8. **Follow the subject requirements** strictly

### Useful Commands Cheat Sheet

```bash
# Quick status check
docker compose -f srcs/docker-compose.yml ps

# Rebuild specific service
docker compose -f srcs/docker-compose.yml build <service>

# View resource usage
docker stats

# Clean up everything
make fclean

# Interactive debugging
docker exec -it <container> /bin/bash

# Follow logs
docker compose -f srcs/docker-compose.yml logs -f <service>

# Check container IP
docker inspect <container> | grep IPAddress
```
