FROM php:8.1.2-apache

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        unzip \
        && rm -rf /var/lib/apt/lists/*

# Install PDO MySQL driver
RUN docker-php-ext-install pdo_mysql

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html/

# Copy the application files
COPY --chown=www-data:www-data . .

# Copy Apache configuration
COPY --chown=www-data:www-data default.conf /etc/apache2/sites-enabled/000-default.conf

# Set the ServerName to suppress the Apache warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Enable Apache modules and site
RUN a2enmod rewrite && \
    a2ensite 000-default
# Install composer dependencies (excluding scripts and autoloader optimization)
RUN composer install --no-scripts --no-autoloader

# Run composer scripts (e.g., database migrations, etc.)
RUN composer dump-autoload --no-scripts

ENV DB_CONNECTION=mysql
ENV DB_HOST=localhost
ENV DB_PORT=3306
ENV DB_DATABASE=backend_api
ENV DB_USERNAME=root
ENV DB_PASSWORD=password

# Expose port 80 for Apache
EXPOSE 80
