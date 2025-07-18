# 🧱 Magento 2 Dockerized Setup – Technical Assessment

This project provides a complete Docker-based Magento 2.4.x environment configured for secure, scalable, and maintainable local development and deployment.

> Developed as part of a technical assessment. The setup is production-aligned and supports sample data, Redis cache/session handling, Elasticsearch search, PHPMyAdmin DB GUI, Varnish caching, HTTPS via self-signed certs, and health checks.

---

## ✅ Project Highlights

- Magento 2.4.x Community Edition (via Composer)
- Redis integration for cache and session
- Elasticsearch 8.x support
- MySQL 8 backend with persistent volume
- PHP-FPM (8.3) tuned for Magento
- NGINX reverse proxy + SSL
- Varnish full-page cache
- PHPMyAdmin for DB GUI access
- Idempotent installation logic
- Unified `www-data` user across stack
- Health check script for service and URL validation
- Dockerized with a single custom network and modular structure
- Static content optimization and proper NGINX configuration

---

## 🏗️ Tech Stack

| Component       | Version        |
|-----------------|----------------|
| Magento         | 2.4.x          |
| PHP             | 8.3            |
| MySQL           | 8.0            |
| Redis           | alpine         |
| Elasticsearch   | 8.11.0         |
| NGINX           | 1.28.0         |
| Varnish         | 7.4.2          |
| PHPMyAdmin      | latest         |
| Docker Compose  | v3.8           |

---

## 🗂️ Directory Structure

```bash
magento2-docker/
├── docker-compose.yml
├── .env
├── .gitignore
├── health-check.sh
├── README.md
├── auth/
│   └── auth.json
├── magento/                    # Magento application files
├── docker/
│   ├── php/
│   │   ├── Dockerfile
│   │   ├── install-magento.sh
│   │   ├── php.ini
│   │   └── www.conf
│   ├── nginx/
│   │   ├── Dockerfile
│   │   ├── nginx.conf
│   │   └── default.conf
│   └── varnish/
│       ├── Dockerfile
│       └── default.vcl  
└── certs/
    ├── server.crt
    └── server.key
```

---

## 🚀 Setup Instructions

### 1. Clone and Generate SSL Certs

```bash
git clone <repo-url>
cd magento2-docker

mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/server.key \
  -out certs/server.crt \
  -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=MagentoDocker/CN=34.31.227.51"
```

---

### 2. Add Magento Marketplace Keys

Create `auth/auth.json`:

```json
{
  "http-basic": {
    "repo.magento.com": {
      "username": "<magento-authentication-public-key>",
      "password": "<magento-authentication-private-key>"
    }
  }
}
```

---

### 3. Configure `.env`

```env
MAGENTO_BASE_URL=https://<your-server-ip>/
MAGENTO_ADMIN_EMAIL=<admin-email>
MAGENTO_ADMIN_USER=<admin-username>
MAGENTO_ADMIN_PASS=<admin-password>

DB_NAME=<db-name>
DB_USER=<db-user>
DB_PASSWORD=<db-pass>

MAGENTO_REPO_PUBLIC_KEY=<magento-repo-public-key>
MAGENTO_REPO_PRIVATE_KEY=<magento-repo-private-key>
```

---

### 4. Start the Stack

```bash
docker-compose up -d
```

Magento will automatically install inside the `php-fpm` container via the `install-magento.sh` script.

---

### 5. Check Health

```bash
./health-check.sh
```

---

## 🔗 Service Access

| Service       | URL                                                      |
| ------------- | -------------------------------------------------------- |
| Magento Store | [https://34.31.227.51/](https://34.31.227.51/)         |
| Magento Admin | [https://34.31.227.51/admin](https://34.31.227.51/admin) |
| PHPMyAdmin    | [http://34.31.227.51:8080](http://34.31.227.51:8080)   |
| Elasticsearch | [http://34.31.227.51:9200](http://34.31.227.51:9200)   |
| Varnish Cache | [http://34.31.227.51:6081](http://34.31.227.51:6081)   |

---

## 🔑 Access Credentials

### Magento Admin Panel
- **URL:** https://34.31.227.51/admin
- **Username:** `admin`
- **Password:** `Admin123@`
- **Email:** `archiesgurav10@gmail.com`

### PHPMyAdmin Database Access
- **URL:** http://34.31.227.51:8080
- **Username:** `magento` (or `root` for full access)
- **Password:** `magento123` (or `root` for root user)
- **Database:** `magento`

---

## ⚙️ Health Check Features

The health check script validates:

* ✅ MySQL connectivity via `mysqladmin ping`
* ✅ Redis connectivity via `redis-cli PONG`
* ✅ Elasticsearch cluster health
* ✅ Magento storefront accessibility (HTTP 200/302)
* ✅ PHPMyAdmin interface availability
* ✅ All services running status

---

## 🔧 Technical Implementation Details

### Static Content Optimization
- NGINX configured with proper static file serving
- Magento static content versioning disabled for optimal performance
- CSS, JS, fonts, and media files properly cached
- Gzip compression enabled for better performance

### Varnish Configuration
- Full-page caching enabled on port 6081
- Backend configured to connect to NGINX HTTP (port 80)
- Cache headers properly configured
- TTL set to 5 minutes for optimal performance

### Security Features
- HTTPS enabled with self-signed certificates
- All services isolated in custom Docker network
- No unnecessary ports exposed
- Proper file permissions and ownership

---

## 🚀 Deployment Status

✅ **Successfully Deployed on Google Cloud Platform**
- **Public IP:** 34.31.227.51
- **All Services:** Running and accessible
- **Static Content:** Optimized and serving correctly
- **Varnish Cache:** Operational on port 6081
- **Health Checks:** All services passing

---

## 🔐 Security Considerations

* Self-signed SSL certificates for HTTPS (replace with valid certs for production)
* All services run in isolated `magento` Docker network
* Database credentials should be changed for production use
* Magento admin credentials should be updated for production
* File permissions properly configured for security
* No unnecessary services or ports exposed

---

For further enhancements:
- We can Integrate CI/CD pipelines for automated builds and deployments.
- Add monitoring via Prometheus, Grafana, or AWS CloudWatch.
- Enable centralized logging with ELK or Loki.

---

**Built for assessment and real-world deployment by Archies Gurav.**

## ⚠️ Reviewer Note:
This live deployment and its credentials are shared strictly for assessment purposes.

All credentials will be rotated and public access revoked after evaluation.
