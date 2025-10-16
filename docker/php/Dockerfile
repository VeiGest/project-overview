# Dockerfile para PHP-FPM com extensões necessárias para o VeiGest
FROM php:8.2-fpm-alpine

# Instalar dependências do sistema
RUN apk add --no-cache \
    git \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    icu-dev \
    oniguruma-dev

# Configurar extensões GD
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Instalar extensões PHP
RUN docker-php-ext-install \
    pdo \
    pdo_mysql \
    mysqli \
    zip \
    gd \
    intl \
    mbstring \
    opcache \
    bcmath

# Instalar Redis extension
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Definir diretório de trabalho
WORKDIR /var/www/html

# Copiar arquivos PHP de configuração
COPY ./docker/php/php.ini /usr/local/etc/php/conf.d/99-custom.ini

# Criar usuário para executar a aplicação
RUN addgroup -g 1000 www && adduser -u 1000 -G www -s /bin/sh -D www

# Alterar proprietário dos arquivos
RUN chown -R www:www /var/www/html

# Definir usuário
USER www

# Expor porta
EXPOSE 9000

CMD ["php-fpm"]
