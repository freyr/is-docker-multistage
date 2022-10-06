FROM php:8.1-fpm-alpine3.16 as os
RUN apk add --virtual .build-deps $PHPIZE_DEPS \
    && apk add \
    bash \
    vim \
    nginx \
    supervisor \
    && pecl install \
    xdebug-3.1.5 \
    && docker-php-ext-enable xdebug \
    && apk del .build-deps $PHPIZE_DEPS \
    && docker-php-source delete
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

RUN rm /etc/nginx/nginx.conf && chown -R www-data:www-data /var/www/html /run /var/lib/nginx /var/log/nginx
COPY .image/common/nginx.conf /etc/nginx/nginx.conf
COPY .image/common/*.ini $PHP_INI_DIR/conf.d/
COPY .image/common/php-fpm.conf /usr/local/etc/php-fpm.d/php-fpm.conf
COPY .image/common/supervisord-php-fpm-nginx.conf /etc/supervisor/supervisord-php-fpm-nginx.conf

WORKDIR /app
RUN chown -R www-data:www-data /app
COPY --chown=www-data:www-data . .
USER www-data
RUN composer install --no-interaction --prefer-dist --no-autoloader --optimize-autoloader
EXPOSE 8080
ENTRYPOINT [ "/app/docker-entrypoint.sh" ]
