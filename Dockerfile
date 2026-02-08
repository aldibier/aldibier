# Dockerfile alternativo para Coolify (si nixpacks no funciona)
FROM php:8.3-fpm-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache \
    nginx \
    supervisor \
    bash \
    curl \
    git \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    libxml2-dev \
    libxslt-dev \
    mysql-client \
    nodejs \
    npm

# Instalar extensiones PHP requeridas por Drupal 11
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo \
        pdo_mysql \
        mysqli \
        opcache \
        zip \
        intl \
        bcmath \
        soap \
        exif \
        calendar \
        sockets \
        dom \
        xml \
        xmlreader \
        xmlwriter \
        simplexml

# Instalar APCu
RUN pecl install apcu && docker-php-ext-enable apcu

# Configurar PHP
COPY docker/php.ini /usr/local/etc/php/conf.d/drupal.ini

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Configurar Nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/http.d/default.conf

# Configurar Supervisor
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Establecer directorio de trabajo
WORKDIR /var/www/html

# Copiar archivos del proyecto
COPY --chown=www-data:www-data . .

# Instalar dependencias de Composer
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist

# Crear directorios necesarios
RUN mkdir -p web/sites/default/files \
    && chmod -R 775 web/sites/default/files \
    && chown -R www-data:www-data web/sites/default/files

# Copiar y dar permisos al script de entrada
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Exponer puerto (Coolify usa la variable PORT)
EXPOSE ${PORT:-8080}

# Comando de inicio
CMD ["/entrypoint.sh"]
