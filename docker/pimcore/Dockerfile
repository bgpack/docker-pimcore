FROM bgpid/pimcore-php:8.3 AS pimcore-php-installed
LABEL maintainer="Victor Goetsch <v.goetsch@bgpack.ch>"

ARG SKELETON_TAG=v2024.4.1
ARG PIMCORE_VERSION=2024.4.1
RUN cd /opt && git clone --branch $SKELETON_TAG --depth=1 https://github.com/pimcore/skeleton /opt/pimcore \
    && cd /opt/pimcore \
    && rm -Rf .git \
    && mkdir -p /root/.composer
WORKDIR /opt/pimcore
#RUN sed -i -e "s#pimcore\": \"\^10.5#pimcore\": \"$PIMCORE_VERSION#" composer.json

ENV COMPOSER_MEMORY_LIMIT=-1
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN echo "BASE SKELETON INSTALL"
RUN --mount=type=secret,id=bgpid,uid=0 \
    --mount=type=cache,mode=0777,uid=0,target=/root/.composer/cache \
    cd /opt/pimcore && composer config -g github-oauth.github.com $(cat /run/secrets/bgpid) \
    && composer install \
    && rm /root/.composer/auth.json

RUN echo "DATA HUB BUNDLE INSTALL"
RUN --mount=type=secret,id=bgpid,uid=0 \
    --mount=type=cache,mode=0777,uid=0,target=/root/.composer/cache \
    cd /opt/pimcore && composer config -g github-oauth.github.com $(cat /run/secrets/bgpid) \
    && composer require pimcore/data-hub \
    && rm /root/.composer/auth.json


RUN echo "DATA IMPORTER BUNDLE INSTALL"
RUN --mount=type=secret,id=bgpid,uid=0 \
    --mount=type=cache,mode=0777,uid=0,target=/root/.composer/cache \
    cd /opt/pimcore && composer config -g github-oauth.github.com $(cat /run/secrets/bgpid) \
    && composer require pimcore/data-importer \
    && rm /root/.composer/auth.json


RUN echo "REMOVE AUTO UPDATE FROM PIMCORE SCRIPTS"
RUN mv composer.json composer.jq.json \
    && jq 'del(.scripts["post-update-cmd"])' composer.jq.json > composer.json \
    && rm composer.jq.json
RUN cp composer.json composer.lock /opt/ \
    && cp composer.json /opt/composer.orig.json \
    && cp composer.lock /opt/composer.orig.lock
RUN sed -i -e "s#memory_limit = 128M#memory_limit = 512M#" /usr/local/etc/php/php.ini-development \
    && sed -i -e "s#post_max_size = 8M#post_max_size = 50M#" /usr/local/etc/php/php.ini-development \
    && sed -i -e "s#upload_max_filesize = 2M#upload_max_filesize = 50M#" /usr/local/etc/php/php.ini-development
RUN sed -i -e "s#memory_limit = 128M#memory_limit = 512M#" /usr/local/etc/php/php.ini-production \
    && sed -i -e "s#post_max_size = 8M#post_max_size = 50M#" /usr/local/etc/php/php.ini-production \
    && sed -i -e "s#upload_max_filesize = 2M#upload_max_filesize = 50M#" /usr/local/etc/php/php.ini-production


FROM pimcore-php-installed AS pimcore-php-debug
ADD files.tar.gz /files

RUN set -eux; \
    \
    build-install.sh; \
    \
    pecl install xdebug; \
    docker-php-ext-enable xdebug; \
    \
    build-cleanup.sh; \
    \
    # For local development, it should be possible to use any local (Git) Composer repository - that's safe in debug image flavor
    git config --global --add safe.directory "*"; \
    \
    # Allow running as an arbitrary user, as the config will be changed through
    # the entrypoint.sh script
    chmod -R 0777 /usr/local/etc/php/conf.d/

ENV PHP_IDE_CONFIG serverName=localhost

#COPY --chmod=0755 /files/entrypoint.sh /usr/local/bin/
RUN cp /files/entrypoint.sh /usr/local/bin/ && chmod 0755 /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]


FROM pimcore-php-installed AS pimcore-php-supervisord
ADD files.tar.gz /files

RUN set -eux; \
    \
    apt-get update; \
    apt-get install -y \
        cron \
        supervisor \
    ; \
    \
    chmod gu+rw /var/run; \
    chmod gu+s /usr/sbin/cron

#COPY /files/conf/supervisord/supervisord.conf /etc/supervisor/supervisord.conf
RUN cp /files/conf/supervisord/supervisord.conf /etc/supervisor/supervisord.conf


CMD ["/usr/bin/supervisord"]
