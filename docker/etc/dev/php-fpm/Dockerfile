FROM php:8.4-fpm

RUN rm -f /etc/apt/apt.conf.d/docker-clean; \
    echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache

RUN set -eux; \
    apt update && apt upgrade -y && apt-get install -y --no-install-recommends \
    git \
    zip \
    unzip \
    libjpeg62-turbo-dev \
    libpng-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    pkg-config \
    libssl-dev \
    libpq-dev \
    libmagickwand-dev \
    ghostscript \
    zlib1g-dev \
    libicu-dev \
    gettext \
    cron \
    libpcre2-dev \
    bash \
    coreutils \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure zip \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install -j$(nproc) \
        gd \
        zip \
        iconv \
        pdo \
        pdo_pgsql \
        pdo_mysql \
        mbstring \
        exif \
        intl \
        curl \
        bcmath \
        gettext \
        pcntl

RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

ARG CURRENT_USER
ARG CURRENT_GROUP

RUN sed -i "s/user = www-data/user = ${CURRENT_USER}/g" /usr/local/etc/php-fpm.d/www.conf && \
    sed -i "s/group = www-data/group = ${CURRENT_GROUP}/g" /usr/local/etc/php-fpm.d/www.conf

RUN if ! getent group ${CURRENT_GROUP} > /dev/null 2>&1; then \
        groupadd -r -g 1000 ${CURRENT_GROUP}; \
    fi

RUN if ! getent passwd ${CURRENT_USER} > /dev/null 2>&1; then \
        useradd -r -u 1000 -g ${CURRENT_GROUP} ${CURRENT_USER}; \
    else \
        usermod -aG ${CURRENT_GROUP} ${CURRENT_USER}; \
    fi

USER $CURRENT_USER

ARG DIR_BASE
WORKDIR $DIR_BASE

EXPOSE 9000
CMD ["php-fpm"]