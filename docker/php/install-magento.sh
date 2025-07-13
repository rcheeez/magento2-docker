#!/bin/bash
set -e

MAGENTO_DIR=/var/www/html

# Wait for MySQL
echo "Waiting for MySQL to be ready..."
until mysqladmin ping -h mysql -u${DB_USER} -p${DB_PASSWORD} --silent; do
  echo "MySQL not yet ready. Retrying in 3s..."
  sleep 3
done
echo "MySQL is up."

# Wait for Redis
echo "Waiting for Redis to be ready..."
until redis-cli -h redis ping | grep -q PONG; do
  echo "Redis not yet ready. Retrying in 3s..."
  sleep 3
done
echo "Redis is up."

# Wait for Elasticsearch
echo "Waiting for Elasticsearch to be ready..."
until curl -s http://elasticsearch:9200 | grep -q "cluster_name"; do
  echo "Elasticsearch not yet ready. Retrying in 3s..."
  sleep 3
done
echo "Elasticsearch is up."

# Check if already installed
if [ ! -f "$MAGENTO_DIR/app/etc/env.php" ]; then
  echo "Installing Magento..."

  cd "$MAGENTO_DIR"
  
  # Download Magento source if not exists
  if [ ! -f "composer.json" ]; then
    echo "Creating Magento project..."
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition . --no-install
    
    echo "Installing dependencies (ignoring FTP requirement)..."
    composer install --ignore-platform-req=ext-ftp
  fi

  # Set permissions before install
  find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} + 2>/dev/null || true
  find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} + 2>/dev/null || true

  # Run Magento install only if not already done
  if [ ! -f "app/etc/env.php" ]; then
    echo "Installing Magento with admin user: ${MAGENTO_ADMIN_USER}"
    php bin/magento setup:install \
      --base-url="${MAGENTO_BASE_URL}" \
      --db-host=mysql \
      --db-name="${DB_NAME}" \
      --db-user="${DB_USER}" \
      --db-password="${DB_PASSWORD}" \
      --admin-firstname="Admin" \
      --admin-lastname="User" \
      --admin-email="${MAGENTO_ADMIN_EMAIL}" \
      --admin-user="${MAGENTO_ADMIN_USER}" \
      --admin-password="${MAGENTO_ADMIN_PASS}" \
      --language=en_US \
      --currency=USD \
      --timezone=America/Chicago \
      --use-rewrites=1 \
      --search-engine=elasticsearch8 \
      --elasticsearch-host=elasticsearch \
      --elasticsearch-port=9200 \
      --elasticsearch-index-prefix=magento2 \
      --elasticsearch-timeout=15 \
      --backend-frontname=admin

    echo "Deploying sample data..."
    bin/magento sampledata:deploy || echo "Sample data deployment failed, continuing..."

    echo "Finishing setup..."
    bin/magento setup:upgrade
    bin/magento setup:di:compile
    bin/magento setup:static-content:deploy -f
    bin/magento indexer:reindex
    bin/magento cache:flush

    echo "Configuring Redis for cache and sessions..."
    bin/magento setup:config:set \
      --cache-backend=redis \
      --cache-backend-redis-server=redis \
      --cache-backend-redis-db=0

    bin/magento setup:config:set \
      --session-save=redis \
      --session-save-redis-host=redis \
      --session-save-redis-log-level=3 \
      --session-save-redis-db=1

    echo "Magento installation completed successfully."
  fi

  # Set final permissions for www-data
  echo "Setting permissions..."
  chown -R www-data:www-data "$MAGENTO_DIR"
else
  echo "Magento is already installed. Skipping installation."
fi

# Start PHP-FPM
exec php-fpm

