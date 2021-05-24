FROM ubuntu:18.04

# Set variables that help to avoid script interuption
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Europe/Kiev"

# Set working directory
WORKDIR /root

# Define build arguments
ARG MYSQL_ROOT_PASSWORD 
ARG MYSQL_DATABASE
ARG MYSQL_USER
ARG MYSQL_PASSWORD

# Update system
RUN apt update && apt upgrade -y

# Install and Start MySQL Server
RUN apt install mysql-server-5.7 -y

# Create setup script
RUN echo "CREATE DATABASE ${MYSQL_DATABASE}; \
    CREATE USER '${MYSQL_USER}' IDENTIFIED BY '${MYSQL_PASSWORD}'; \ 
    GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'; \
    FLUSH PRIVILEGES;" > "setup.sql"

# Run setup script
RUN \
    service mysql restart && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    sed -i 's/^\(log_error\s.*\)/# \1/' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    echo "mysqld_safe &" > /tmp/config && \
    echo "mysqladmin --silent --wait=30 ping || exit 1" >> /tmp/config && \
    echo "mysql -uroot -e \"source setup.sql\"" > /tmp/conf && \
    bash /tmp/conf && \
    rm -f /tmp/conf

# Remove setup file
RUN rm setup.sql

# Start MySQL Server
CMD ["sh", "-c", "service mysql start "]
ENTRYPOINT ["sh", "-c", "service mysql start && /bin/bash"]