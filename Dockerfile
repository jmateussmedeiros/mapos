FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libonig-dev \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        zip \
        xml \
        intl \
        mbstring \
        exif

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN a2enmod rewrite

WORKDIR /var/www/html
COPY . .

RUN composer install --no-dev --optimize-autoloader

# Cria os diretórios de upload se não existirem e ajusta permissões
RUN mkdir -p /var/www/html/assets/uploads \
             /var/www/html/assets/arquivos \
             /var/www/html/assets/anexos \
             /var/www/html/assets/userimage && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/assets

EXPOSE 80
