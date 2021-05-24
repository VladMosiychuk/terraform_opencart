FROM ubuntu:20.04

# Set variables that help to avoid script interuption
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Kiev"

# Update system
RUN apt update && apt upgrade -y

# Install Git
RUN apt install git -y

# Install NGINX
RUN apt install nginx -y

# Now we need to install PHP FPM
RUN apt install php7.4-fpm -y

# Install additional plugins for PHP
RUN apt install php-cli php-common php-mbstring php-gd \
    php-intl php-xml php-mysql php-zip php-curl php-xmlrpc -y

# Create directory for PHP-FPM socket file
RUN mkdir -p /run/php/

# Copy config file for Opencart
COPY opencart /etc/nginx/sites-available/default

# Setup new Server Block for Opencart
RUN mkdir -p /var/www/opencart/html

# Download Opencart into this folder (/var/www/opencart/html)
RUN git clone https://github.com/softservedata/lv590.git /tmp/oc \
    && git -C /tmp/oc checkout opencart3 \
    && cp /tmp/oc/opencart/upload/config-dist.php /tmp/oc/opencart/upload/config.php \
    && cp /tmp/oc/opencart/upload/admin/config-dist.php /tmp/oc/opencart/upload/admin/config.php \
    && mv /tmp/oc/opencart/upload/* /var/www/opencart/html \
    && rm -rf /tmp/oc

# Make sure directories have proper rights
# RUN chown -R www-data:www-data /var/www/opencart/html \
RUN chown -R www-data:www-data /var/www/opencart \
    && chmod -R 755 /var/www/opencart

# Open HTTP Port
EXPOSE 80

# Start PHP-FPM and NGINX
CMD ["sh", "-c", "service php7.4-fpm start && service nginx start"]
ENTRYPOINT ["sh", "-c", "service php7.4-fpm start && service nginx start && /bin/bash"]