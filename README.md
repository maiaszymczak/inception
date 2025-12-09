# Inception

*This project has been created as part of the 42 curriculum by mszymcza.*

## Description

Inception is a system administration project that focuses on containerization using Docker. The goal is to set up a small infrastructure composed of different services following specific rules. This project creates a LEMP stack (Linux, Nginx, MariaDB, PHP) using Docker containers, where each service runs in its own dedicated container built from a custom Dockerfile.

The infrastructure consists of:
- **NGINX** with TLSv1.3 only
- **WordPress** with php-fpm (without nginx)
- **MariaDB** (without nginx)

All services communicate through a custom Docker network and use volumes for data persistence.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- Make utility
- At least 2GB of free disk space

### Compilation and Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd inception
```

2. Create a `.env` file in the `srcs/` directory with the following variables:
```bash
# Domain
DOMAIN_NAME=mszymcza.42.fr

# MariaDB Configuration
MYSQL_ROOT_PASSWORD=<your_root_password>
MYSQL_DATABASE=wordpress
MYSQL_USER=<your_db_user>
MYSQL_PASSWORD=<your_db_password>

# WordPress Configuration
WP_ADMIN_USER=<admin_username>
WP_ADMIN_PASSWORD=<admin_password>
WP_ADMIN_EMAIL=<admin_email>
WP_USER=<regular_user>
WP_USER_EMAIL=<user_email>
WP_USER_PASSWORD=<user_password>
WP_TITLE="My WordPress Site"
WP_URL=https://mszymcza.42.fr
```

3. Update your `/etc/hosts` file to point your domain to localhost:
```bash
sudo echo "127.0.0.1 mszymcza.42.fr" >> /etc/hosts
```

### Execution

Build and start all services:
```bash
make
```

Other useful commands:
- `make down` - Stop all containers
- `make restart` - Restart all services
- `make logs` - View container logs
- `make clean` - Stop containers and remove volumes
- `make fclean` - Full cleanup including Docker system prune
- `make re` - Rebuild everything from scratch

### Access

Once running, access the services at:
- **WordPress site**: https://mszymcza.42.fr
- **WordPress admin panel**: https://mszymcza.42.fr/wp-admin

## Resources

### Documentation
- [Docker Official Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [WordPress Documentation](https://wordpress.org/documentation/)
- [WP-CLI Documentation](https://wp-cli.org/)

### Tutorials
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Understanding Docker Networks](https://docs.docker.com/network/)
- [Docker Volumes Guide](https://docs.docker.com/storage/volumes/)
- [Setting up WordPress with Docker](https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/)

## Project Description

### Docker in this Project

This project leverages Docker to create isolated, reproducible environments for each service. Each service (NGINX, WordPress, MariaDB) runs in its own container built from a custom Dockerfile based on the penultimate stable version of Debian (bookworm).

**Why Docker?**
- **Isolation**: Each service runs independently without conflicts
- **Portability**: The entire stack can be deployed anywhere Docker runs
- **Reproducibility**: Identical environments across development and production
- **Resource Efficiency**: Lighter than virtual machines, faster startup times

### Design Choices

1. **Custom Dockerfiles**: All images are built from scratch using Debian bookworm, avoiding pre-built images from Docker Hub (except the base Debian image)

2. **Dedicated Containers**: Each service runs in a separate container following the single-responsibility principle

3. **Custom Network**: A dedicated bridge network (`inception`) isolates the services from other Docker networks while allowing inter-container communication

4. **Persistent Storage**: Bind mounts to `~/data/` ensure data persists across container restarts

5. **Environment Variables**: Sensitive configuration is stored in a `.env` file, keeping credentials out of version control

6. **TLS/SSL**: NGINX is configured with a self-signed certificate for HTTPS-only access

### Virtual Machines vs Docker

**For this project**: Docker is preferred because we need lightweight, fast-deploying services that share the same OS kernel. VMs would be overkill for running a simple LEMP stack.

### Secret vs env

**For this project**: Environment variables are used for simplicity as required by the subject. In production, sensitive data (database passwords, API keys) should be managed using Docker secrets or external secret managers.

### Docker Network vs Host Network

**For this project**: A custom bridge network (`inception`) is used to:
- Isolate services from the host and other containers
- Enable automatic DNS resolution between containers (wordpress → mariadb)
- Control which ports are exposed to the host (only 443)

### Docker Volumes vs Bind Mounts

**For this project**: Bind mounts to `~/data/` are used because:
- The subject requires volumes to be available in `/home/login/data`
- Easier to access and backup from the host filesystem
- Simpler permission management during development
- Data location is explicit and predictable

The `docker-compose.yml` defines Docker volumes that use bind mounts under the hood, combining the benefits of both approaches.

---

For detailed usage instructions, see [USER_DOC.md](USER_DOC.md).  
For development setup, see [DEV_DOC.md](DEV_DOC.md).
