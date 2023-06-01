# Base image
FROM php:8.1.2-apache

# Set working directory
WORKDIR /var/www/html

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf
# Copy project files
COPY . .
RUN cp .env.example .env
#RUN php artisan key:generate
# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && a2enmod rewrite

# Install Laravel dependencies
RUN composer update
RUN composer install

RUN chmod -R 777 storage && chmod -R 777 bootstrap/cache

 
# Set up MySQL
#ENV MYSQL_ROOT_PASSWORD=password
#ENV MYSQL_DATABASE=sample_app_db
#ENV MYSQL_USER=appuser
#ENV MYSQL_PASSWORD=password

# Install MySQL client
#RUN apt-get install -y default-mysql-client
#RUN php artisan migrate:fresh
# Expose Apache port
EXPOSE 80
#EXPOSE 3306
# Start Apache service
CMD ["apache2-foreground"]
