# VERSION 1.0.0
# DESCRIPTION: ubi8, php 8.2, osticket 1.18.x
# DOCKER_HUB_REPOSITORY: eveanwarl0ck/osticket_1_18_x
FROM registry.access.redhat.com/ubi8/ubi

LABEL maintainer="0zymandia5"

ENV OSTICKET_VERSION=1.18.x
ENV OSTICKET_HOME=/var/www/html/osTicket
ENV PHP_VERSION=8.2

# Install al dependecnies
RUN dnf install -y httpd \
    && dnf module enable php:$PHP_VERSION -y \
    && dnf install -y php \
    php-mysqlnd \
    php-pdo \
    php-gd \
    php-mbstring \
    php-xml \
    php-json \
    php-fpm \
    git \
    && dnf clean all

# Copy the configuration file for PHP and HTTPD
COPY php.ini /etc/php.ini
COPY httpd.conf /etc/httpd/conf/httpd.conf

# Clone the repository, checkout to the correct version and put the Osticket files into /var/www/html
RUN git clone https://github.com/osTicket/osTicket.git
RUN mkdir $OSTICKET_HOME
RUN cd osTicket && git checkout $OSTICKET_VERSION && mv * $OSTICKET_HOME
COPY ost-config.php $OSTICKET_HOME/include
RUN rm -R osTicket

# Set permissions for apache user
RUN chown -R apache:apache /var/www/html

# Open port 80
EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]