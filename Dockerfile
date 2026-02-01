FROM php:8.4-apache

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    zip \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    libzip-dev \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Baixar script oficial do Docker PHP e instalar extensões
RUN curl -fsSL https://raw.githubusercontent.com/docker-library/scripts/master/php/docker-php-install-script -o /usr/local/bin/docker-php-install-script && \
    chmod +x /usr/local/bin/docker-php-install-script && \
    docker-php-install-script && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
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

# Instalar Composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# Habilitar mod_rewrite no Apache
RUN a2enmod rewrite

# Copiar código do MapOS
WORKDIR /var/www/html
COPY . .

# Instalar dependências PHP
RUN composer install --no-dev --optimize-autoloader

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 775 /var/www/html/assets

EXPOSE 80
