FROM ghcr.io/rkojedzinszky/webhost-images/php7 AS base

LABEL maintainer="Richard Kojedzinszky <richard@kojedz.in>"

ENV PHPIPAM_VER 1.5.0

USER 0

# Install common packages
RUN apk --no-cache add \
    iputils fping

# Do the installation
RUN mkdir -p /var/www/html && \
    apk --no-cache add -t .install curl && \
    curl -sL https://github.com/phpipam/phpipam/archive/v${PHPIPAM_VER}.tar.gz | \
    tar xzf - -C /var/www/html --strip-components=1 && \
    apk --no-cache del .install && \
    ln -s config.docker.php /var/www/html/config.php && \
    echo "getenv('IPAM_TIMEZONE') ? date_default_timezone_set(getenv('IPAM_TIMEZONE')) : false;" >> /var/www/html/config.php && \
    find /var/www/html -name upload -type d -print0 | xargs -r0 chown apache

USER 8080
