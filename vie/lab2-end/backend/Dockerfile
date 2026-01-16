FROM php:8.2-apache

# Установка расширений PHP для PostgreSQL
RUN apt-get update && apt-get install -y \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Включение mod_rewrite
RUN a2enmod rewrite

# Копирование конфигурации Apache
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf

EXPOSE 80

