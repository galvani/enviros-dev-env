FROM php:8.3-fpm

# Maintainer information (optional)
LABEL maintainer="Jan Kozak <galvani78@gmail.com>"

# Install necessary tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    acl \
    cron \
    curl \
    git \
    iproute2 \
    libc-client-dev \
    libcurl4-openssl-dev \
    libedit-dev \
    libfreetype6-dev \
    libgmp-dev \
    libicu-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libkrb5-dev \
    libldap2-dev \
    libmcrypt-dev \
    libonig-dev \
    libpng-dev \
    libpq-dev \
    libpq5 \
    libsqlite3-dev \
    librabbitmq-dev \
    libssl-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libz-dev \
    libzip-dev \
    lsb-release \
    net-tools \
    netcat-traditional \
    openssl \
    sqlite3 \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev && apt-get clean && rm -rf /var/lib/apt/lists/*


# Install the PHP Extension Installer
RUN curl -fsSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    -o /usr/local/bin/install-php-extensions && chmod +x /usr/local/bin/install-php-extensions

# Install PHP extensions
RUN install-php-extensions \
    pdo_mysql \
    intl \
    mysqli \
    mbstring \
    opcache \
    zip \
    gd \
    xml \
    curl \
    bcmath \
    json \
    calendar \
    xdebug \
    redis \
    igbinary

RUN docker-php-ext-enable calendar

# Configure the PHP settings
COPY ./php.ini /usr/local/etc/php/php.ini
COPY ./docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/
COPY ./www.conf /usr/local/etc/php-fpm.d/www.conf
# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Set the working directory
WORKDIR /var/www/enviros

# Default command (entry point)
CMD ["php-fpm"]

# Expose the PHP-FPM port
EXPOSE 9000