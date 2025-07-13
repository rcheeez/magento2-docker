FROM php:8.3-fpm

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including mysql-client and redis-tools
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
    default-mysql-client \
    redis-tools \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring zip exif pcntl intl xsl soap opcache gd bcmath ftp sockets \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy install script
COPY install-magento.sh /usr/local/bin/install-magento
RUN chmod +x /usr/local/bin/install-magento

WORKDIR /var/www/html

ENTRYPOINT ["install-magento"]

