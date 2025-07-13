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
- Unified `test-ssh:clp` Linux user across stack
- Health check script for service and URL validation
- Dockerized with a single custom network and modular structure

---

## 🏗️ Tech Stack

| Component       | Version        |
|-----------------|----------------|
| Magento         | 2.4.x          |
| PHP             | 8.3            |
| MySQL           | 8.0            |
| Redis           | alpine         |
| Elasticsearch   | 8.11.x         |
| NGINX           | stable         |
| Varnish         | 7.3            |
| PHPMyAdmin      | latest         |
| Docker Compose  | v3.8           |

---

## 🗂️ Directory Structure

```bash
magento-docker/
├── docker-compose.yml
├── .env
├── .gitignore
├── install-magento.sh
├── health-check.sh
├── README.md
├── magento/
│   └── auth.json
├── docker/
│   ├── php/
│   │   ├── Dockerfile
│   │   ├── php.ini
│   │   └── www.conf
│   ├── nginx/
│   │   ├── nginx.conf
│   │   └── default.conf
│   └── varnish/
│       ├── Dockerfile
│       └── default.vcl  
└── certs/
    ├── server.crt
    └── server.key
````

---

## 🚀 Setup Instructions

### 1. Clone and Generate SSL Certs

```bash
git clone <repo-url>
cd magento-docker

mkdir certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout certs/server.key \
  -out certs/server.crt \
  -subj "/C=IN/ST=Maharashtra/L=Mumbai/O=MagentoDocker/CN=localhost"
```

---

### 2. Add Magento Marketplace Keys

Create `magento/auth.json`:

```json
{
  "http-basic": {
    "repo.magento.com": {
      "username": "your-public-key",
      "password": "your-private-key"
    }
  }
}
```

---

### 3. Configure `.env`

```env
MAGENTO_BASE_URL=https://localhost/
MAGENTO_ADMIN_EMAIL=admin@example.com
MAGENTO_ADMIN_USER=admin
MAGENTO_ADMIN_PASS=Admin123@

DB_NAME=magento
DB_USER=magento
DB_PASSWORD=magento123
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

| Service       | URL                                                |
| ------------- | -------------------------------------------------- |
| Magento Store | [https://localhost/](https://localhost/)           |
| Magento Admin | [https://localhost/admin](https://localhost/admin) |
| PHPMyAdmin    | [http://localhost:8080](http://localhost:8080)     |
| Elasticsearch | [http://localhost:9200](http://localhost:9200)     |
| Redis         | localhost:6379                                     |

---

## 👥 Linux User Permissions

To align volume ownership with host and container:

```bash
sudo groupadd clp
sudo useradd -m -s /bin/bash -g clp test-ssh
sudo chown -R test-ssh:clp ./magento
```

* Both `php-fpm` and `nginx` containers run as `test-ssh`
* `www.conf` and `nginx.conf` reflect these users

---

## ⚙️ Health Check Includes:

* MySQL ping via `mysqladmin`
* Redis PONG via `redis-cli`
* Elasticsearch response check
* HTTP status code 200 for:

  * Magento Storefront
  * PHPMyAdmin

---

## 🔐 Security Considerations

* No FTP used or needed (filesystem permissions are handled via UID/GID)
* Self-signed certs for local SSL testing
* All services run in isolated `magento` network

---