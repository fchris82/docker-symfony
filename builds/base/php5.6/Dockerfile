FROM php:5.6-fpm

RUN apt-get clean && apt-get update \
    && apt-get install -y locales wget curl software-properties-common ssh build-essential curl git unzip gettext-base \
        libmcrypt-dev libicu-dev libxslt-dev libxml2-dev libglib2.0-bin libcurl4-gnutls-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev \
    && mkdir -p /home/user/.ssh \
    && mkdir -p /run/php \
    && usermod -d /home/user www-data \
    && chown www-data /home/user \
    && touch /home/user/.gitignore && git config --global core.excludesfile '/home/user/.gitignore' \
    && rm -rf /var/lib/apt/lists/*

ENV GOSU_VERSION 1.10
RUN set -ex; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
    chmod +x /usr/local/bin/gosu; \
# verify that the binary works
    gosu nobody true

# PHP
COPY config/php_requires.txt /tmp/php_requires

RUN docker-php-ext-install -j$(nproc) `grep -vE "^\s*#" /tmp/php_requires | tr "\n" " "` \
    && pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug \
    && pecl install imagick && docker-php-ext-enable imagick \
    && sed -e 's#error_log = .*#error_log = /var/log/php-fpm.log#' -i /usr/local/etc/php-fpm.conf \
    && sed -e 's/listen = .*/listen = \[::\]:9003/' -i /usr/local/etc/php-fpm.d/zz-docker.conf \
    && sed -e 's/;listen\.owner/listen.owner/' -i /usr/local/etc/php-fpm.d/www.conf \
    && sed -e 's/;listen\.group/listen.group/' -i /usr/local/etc/php-fpm.d/www.conf \
    && sed -e 's/;catch_workers_output/catch_workers_output/' -i /usr/local/etc/php-fpm.d/www.conf \
    && sed -e 's/;php_admin_flag[log_errors]/php_admin_flag[log_errors]/' -i /usr/local/etc/php-fpm.d/www.conf \
    && sed -e 's#;php_admin_value[error_log] = .*#php_admin_value[error_log] = /var/log/php/www.log#' -i /usr/local/etc/php-fpm.d/www.conf \
    && curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo \
    && rm -rf /var/lib/apt/lists/*

COPY config/custom.php.ini /usr/local/etc/php/conf.d/99-custom.ini.dist
COPY config/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini.dist

# XDEBUG!
EXPOSE 9000
# PHP-FPM
EXPOSE 9003

COPY bin/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY bin/wait-for-it.sh /usr/local/bin/wait-for-it.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

VOLUME /var/www
WORKDIR /var/www
