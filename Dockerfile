FROM alpine:3.15 AS base

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

ENV PHPIPAM_VER 1.4.5

# Pre-create apache to have constant uid
RUN adduser -h /var/www -s /sbin/nologin -u 8080 -D -H apache

# Install common packages
RUN apk --no-cache add \
    tzdata php-session php-sockets php-gmp php-json php-gettext php-mbstring \
    php-gd php-iconv php-ctype php-curl php-pear php-pdo_mysql php-openssl \
    php-simplexml php-opcache php-pcntl php-posix php-snmp iputils fping

# Do the installation
RUN mkdir -p /var/www/localhost/htdocs && \
    apk --no-cache add -t .install curl && \
    curl -sL https://github.com/phpipam/phpipam/archive/v${PHPIPAM_VER}.tar.gz | \
    tar xzf - -C /var/www/localhost/htdocs --strip-components=1 && \
    apk --no-cache del .install && \
    ln -s config.docker.php /var/www/localhost/htdocs/config.php && \
    echo "getenv('IPAM_TIMEZONE') ? date_default_timezone_set(getenv('IPAM_TIMEZONE')) : false;" >> /var/www/localhost/htdocs/config.php

FROM base AS ui

RUN apk --no-cache add \
    apache2 php-apache2 && \
    rm -f /var/www/localhost/htdocs/index.html /etc/apache2/conf.d/languages.conf && \
    sed -r -i \
      -e 's/^Listen 80/Listen 8080/' \
      -e '/^LoadModule/s/^/#/' \
      -e '/^[[:space:]]+AllowOverride[[:space:]]+[nN]one/s/[nN]one/All/' \
      /etc/apache2/httpd.conf && \
    sed -r -i \
      -e '/LoadModule (mpm_prefork_module|mime_module|log_config_module|authz_core_module|dir_module|unixd_module|rewrite_module)/s/^#+//' \
      /etc/apache2/httpd.conf && \
    sed -i -e '/PidFile/d' /etc/apache2/conf.d/mpm.conf && \
    chown apache /var/log/apache2 /run/apache2 && \
    ln -s /dev/stdout /var/www/logs/access.log && \
    ln -s /dev/stderr /var/www/logs/error.log && \
    httpd -t && \
    find /var/www/localhost/htdocs -name upload -type d -print0 | xargs -r0 chown apache

EXPOSE 8080

USER 8080

CMD ["httpd", "-DFOREGROUND"]
