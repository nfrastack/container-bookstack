# SPDX-FileCopyrightText: © 2025 Nfrastack <code@nfrastack.com>
#
# SPDX-License-Identifier: MIT

ARG BASE_IMAGE

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
    BOOKSTACK_VERSION="v25.12.3" \
    BOOKSTACK_REPO_URL="https://github.com/BookStackApp/BookStack"

COPY CHANGELOG.md /usr/src/container/CHANGELOG.md
COPY LICENSE /usr/src/container/LICENSE
COPY README.md /usr/src/container/README.md

ENV \
    PHP_MODULE_ENABLE_CREATE_SAMPLE_PHP=FALSE \
    PHP_MODULE_ENABLE_LDAP=TRUE \
    PHP_MODULE_ENABLE_SIMPLEXML=TRUE \
    PHP_MODULE_ENABLE_MEMCACHED=TRUE \
    PHP_MODULE_ENABLE_PDO=TRUE \
    PHP_MODULE_ENABLE_PDO_MYSQL=TRUE \
    PHP_MODULE_ENABLE_FILEINFO=TRUE \
    PHP_MODULE_ENABLE_TOKENIZER=TRUE \
    PHP_MODULE_ENABLE_XMLWRITER=TRUE \
    PHP_MODULE_ENABLE_ZIP=TRUE \
    NGINX_WEBROOT=/www/bookstack \
    NGINX_SITE_ENABLED=bookstack \
    CONTAINER_ENABLE_MESSAGING=TRUE \
    IMAGE_NAME="nfrastack/bookstack" \
    IMAGE_REPO_URL="https://github.com/nfrastack/container-bookstack/"

RUN echo "" && \
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
    clone_git_repo "${BOOKSTACK_REPO_URL}" "${BOOKSTACK_VERSION}" /container/data/bookstack/install && \
    build_assets /build-assets/src "${GIT_REPO_BOOKSTACK}" && \
    build_assets scripts && \
    composer install && \
    \
    rm -rf \
           /container/data/bookstack/install/.git \
           /container/data/bookstack/install/*.yml \
           /container/data/bookstack/install/dev \
           /container/data/bookstack/install/php*.xml \
           /container/data/bookstack/install/tests \
           && \
    container_build_log add "BookStack ${BOOKSTACK_VERSION}" "${BOOKSTACK_REPO_URL}" && \
    \
    package remove BOOKSTACK_BUILD_DEPS && \
    package cleanup

COPY rootfs /
