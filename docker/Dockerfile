FROM composer:2.9.3 AS composer
FROM mlocati/php-extension-installer:2.9.25 AS pei
FROM php:8.5.1-apache AS apachephp

FROM apachephp AS basebuild
COPY --from=pei /usr/bin/install-php-extensions /usr/local/bin/install-php-extensions
RUN apt-get update \
    && apt-get install -yq git default-mysql-client unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod rewrite headers ssl mpm_prefork && a2dismod status info
ENV COMPOSER_HOME=/composer \
    PATH=/composer/vendor/bin:$PATH \
    COMPOSER_ALLOW_SUPERUSER=1 \
    DEBCONF_NOWARNINGS=yes
RUN install-php-extensions gd opcache intl zip bcmath pdo_mysql
COPY --from=composer /usr/bin/composer /usr/bin/composer

FROM basebuild AS local
ARG USER_ID
ARG GROUP_ID
ARG USER_NAME
RUN apt-get update \
    && apt-get install -yq \
      dnsutils \
      iproute2 \
      iputils-ping \
      vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -o -g ${GROUP_ID} ${USER_NAME} \
    && useradd -oml -u ${USER_ID} -g ${GROUP_ID} ${USER_NAME} \
    && install -d -o ${USER_NAME} -g ${USER_NAME} /config/psysh /composer /var/www/html \
    && install-php-extensions xdebug
ENV APACHE_RUN_USER=${USER_NAME} \
    APACHE_RUN_GROUP=${USER_NAME} \
    APACHE_LOG_DIR=/var/www/html/storage/logs
USER ${USER_NAME}

FROM golang:1.25.6-trixie AS go

# MinIO Serverのインストール
FROM go AS minio
RUN go install -v github.com/minio/minio@RELEASE.2025-10-15T17-29-55Z

# MinIO Client (mc) のインストール
FROM go AS mc
RUN go install -v github.com/minio/mc@RELEASE.2025-08-13T08-35-41Z

FROM debian:trixie-slim AS s3mock
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY --from=minio /go/bin/minio /usr/local/bin/minio
COPY --from=mc /go/bin/mc /usr/local/bin/mc

COPY s3mock-entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /data

VOLUME ["/data"]

ENV MINIO_ROOT_USER=admin \
    MINIO_ROOT_PASSWORD=password \
    BUCKET_NAME=my-bucket

EXPOSE 9000 9001 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
