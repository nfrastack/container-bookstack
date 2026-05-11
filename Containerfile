# SPDX-FileCopyrightText: © 2026 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE=docker.io/nfrastack/laravel:latest

FROM ${BASE_IMAGE}

LABEL \
        org.opencontainers.image.title="BookStack" \
        org.opencontainers.image.description="Containerized knowledge information tool with included webserver and PHP interpreter" \
        org.opencontainers.image.url="https://hub.docker.com/r/nfrastack/bookstack" \
        org.opencontainers.image.documentation="https://github.com/nfrastack/container-bookstack/blob/main/README.md" \
        org.opencontainers.image.source="https://github.com/nfrastack/container-bookstack.git" \
        org.opencontainers.image.authors="Nfrastack <code@nfrastack.com>" \
        org.opencontainers.image.vendor="Nfrastack <https://www.nfrastack.com>" \
        org.opencontainers.image.licenses="MIT"

ARG \
    BOOKSTACK_VERSION="v26.03.4" \
    BOOKSTACK_REPO_URL="https://github.com/BookStackApp/BookStack"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    IMAGE_NAME="nfrastack/bookstack" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-bookstack/"

RUN echo "" && \
    BUILD_ENV=" \
                10-nginx/NGINX_SITE_ENABLED=bookstack \
                10-nginx/NGINX_WEBROOT=/www/bookstack \
                20-php-fpm/PHP_MODULE_ENABLE_MEMCACHED=TRUE \
                20-php-fpm/PHP_MODULE_ENABLE_ZIP=TRUE \
                30-laravel/LARAVEL_INSTALL_DATA_PATH=/container/data/bookstack \
                30-laravel/LARAVEL_COMPOSER_SETUP=FALSE \
                30-laravel/LARAVEL_CONFIGURE_APP_KEY=TRUE \
                30-laravel/LARAVEL_CONFIGURE_DB=TRUE \
                30-laravel/LARAVEL_COPY_ENV_EXAMPLE=FALSE \
                30-laravel/LARAVEL_ENV_PREFIX=BOOKSTACK \
                30-laravel/ENABLE_LARAVEL_WORKER=FALSE \
                30-laravel/LARAVEL_IMAGE_MODE=production \
                30-laravel/LARAVEL_MIGRATE_ON_FIRST_INSTALL=FALSE \
                30-laravel/LARAVEL_NPM_SETUP=FALSE \
                30-laravel/DB_TYPE=mysql \
                30-laravel/APP_NAME=BookStack \
              " \
              && \
    BOOKSTACK_BUILD_DEPS_ALPINE=" \
                                    git \
                                " \
                                && \
    BOOKSTACK_RUN_DEPS_ALPINE=" \
                                fontconfig \
                                git \
                                jpegoptim \
                                libmemcached \
                                optipng \
                              " \
                              && \
    source /container/base/functions/container/build && \
    container_build_log image && \
    package update && \
    package upgrade && \
    package install \
                    BOOKSTACK_BUILD_DEPS \
                    BOOKSTACK_RUN_DEPS \
                    && \
    php-ext prepare && \
    php-ext reset && \
    php-ext enable core && \
    \
    clone_git_repo "${BOOKSTACK_REPO_URL}" "${BOOKSTACK_VERSION}" "${LARAVEL_INSTALL_DATA_PATH}"/install && \
    build_assets /build-assets/src "${GIT_REPO_BOOKSTACK}" && \
    build_assets scripts && \
    composer install && \
    \
    rm -rf \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/*.dist \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/*.mjs \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/*.ts \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/*.yml \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/.git*\
           "${LARAVEL_INSTALL_DATA_PATH}"/install/.github \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/dev \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/php*.xml \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/tests \
           "${LARAVEL_INSTALL_DATA_PATH}"/install/tsconfig.json \
           && \
    container_build_log add "BookStack ${BOOKSTACK_VERSION}" "${BOOKSTACK_REPO_URL}" && \
    \
    package remove BOOKSTACK_BUILD_DEPS && \
    package cleanup

COPY rootfs /
