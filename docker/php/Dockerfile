FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    unzip \
    git \
    curl \
    libxslt-dev \
    libicu-dev \
    libssl-dev \
    zlib1g-dev \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl intl xsl soap opcache gd bcmath

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy installer
COPY ../install-magento.sh /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

WORKDIR /var/www/html

ENTRYPOINT ["install-magento"]