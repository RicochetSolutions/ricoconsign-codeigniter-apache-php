# ricochetsolutions/ricoconsign-pos-apache-php

FROM php:5.5-apache

MAINTAINER "Austin Maddox" <austin@maddoxbox.com>

RUN apt-get update

RUN apt-get install -y \
    libmcrypt-dev \
    libxml2-dev \
    ssl-cert \
    zlib1g-dev

RUN docker-php-ext-install \
    mcrypt \
    mbstring \
    mysqli \
    soap \
    zip

# Install GD library.
RUN apt-get install -y \
    libpng12-dev \
    libjpeg-dev \
    && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-install gd

# Set the "ServerName" directive globally to suppress this message... "Could not reliably determine the server's fully qualified domain name, using #.#.#.#."
COPY ./etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-available/fqdn.conf
RUN a2enconf fqdn \
    && a2enmod rewrite ssl

# Define the virtual hosts.
COPY ./etc/apache2/sites-available/virtual-hosts.conf /etc/apache2/sites-available/virtual-hosts.conf
RUN a2dissite 000-default \
    && a2ensite virtual-hosts

# If needed, add a custom php.ini configuration.
COPY ./usr/local/etc/php/php.ini /usr/local/etc/php/php.ini

# Cleanup
RUN apt-get clean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 443
