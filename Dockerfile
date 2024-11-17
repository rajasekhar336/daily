# Use official PHP 7.4 image with Apache
FROM php:7.4-apache

# Copy php.ini
COPY php.ini /usr/local/etc/php/

# Install necessary PHP extensions
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    zip \
    git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mysqli

# Install required packages and modules
RUN apt-get update && apt-get install -y apache2-utils

# Enable mod_headers to allow setting HTTP headers
RUN a2enmod headers

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Install Composer (PHP package manager)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set working directory
WORKDIR /var/www/html

# Copy the CodeIgniter project into the container
COPY . .

# Install PHP dependencies using Composer
RUN composer install

# Create a custom security headers file
#RUN echo 'Header always set X-Content-Type-Options "nosniff"' > /etc/apache2/conf-available/security.conf
#RUN echo 'Header always set X-Frame-Options "SAMEORIGIN"' >> /etc/apache2/conf-available/security.conf
#RUN echo 'Header always set X-XSS-Protection "1; mode=block"' >> /etc/apache2/conf-available/security.conf

COPY .docker/vhost.conf /etc/apache2/sites-available/000-default.conf

# Expose port 80 for HTTP
EXPOSE 80

# Start Apache service
CMD ["apache2-foreground"]

