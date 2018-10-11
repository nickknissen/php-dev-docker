FROM php:7.2-fpm-alpine

RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS zlib-dev libltdl libmcrypt-dev \
  && apk add --no-cache libpng-dev freetype-dev libjpeg-turbo-dev \
  && pecl install xdebug \
  && docker-php-ext-enable xdebug \
  \
  && pecl install redis \
  && docker-php-ext-enable redis \
  # extensions used by laravel and most used laravel libs
  && docker-php-ext-install pdo pdo_mysql opcache zip iconv\
  && docker-php-ext-configure gd \
  --with-freetype-dir=/usr/include/ \
  --with-png-dir=/usr/include/ \
  --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install -j$(nproc) gd \
  && apk del .build-deps

RUN echo $'\
  xdebug.remote_enable = 1\n\
  xdebug.remote_autostart = 1\n\
  xdebug.remote_port = 9001\n\
  xdebug.remote_host = host.docker.internal\n\
  xdebug.idekey=PHPSTORM'\
  >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

RUN echo 'date.timezone = "Europe/Copenhagen"', > /usr/local/etc/php/conf.d/tzone.ini

