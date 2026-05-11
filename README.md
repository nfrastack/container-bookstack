# nfrastack/container-bookstack

## About

This repository will build a container image for running [BookStack](https://bookstack.net/) - A knowledge base/information manager.

## Maintainer

* [Nfrastack](https://www.nfrastack.com)

## Table of Contents

* [About](#about)
* [Maintainer](#maintainer)
* [Table of Contents](#table-of-contents)
* [Installation](#installation)
  * [Prebuilt Images](#prebuilt-images)
  * [Quick Start](#quick-start)
  * [Persistent Storage](#persistent-storage)
  * [Environment Variables](#environment-variables)
    * [Base Images used](#base-images-used)
    * [Core Configuration](#core-configuration)
    * [Database](#database)
    * [Application](#application)
    * [Setting Arbitrary BookStack Keys](#setting-arbitrary-bookstack-keys)
    * [Image Optimization](#image-optimization)
    * [Single Sign On Settings](#single-sign-on-settings)
    * [LDAP Scheduled Sync](#ldap-scheduled-sync)
* [Maintenance](#maintenance)
  * [Shell Access](#shell-access)
* [Support & Maintenance](#support--maintenance)
* [References](#references)
* [License](#license)

## Installation

### Prebuilt Images

Feature limited builds of the image are available on the [Github Container Registry](https://github.com/nfrastack/container-bookstack/pkgs/container/container-bookstack) and [Docker Hub](https://hub.docker.com/r/nfrastack/bookstack).

To unlock advanced features, one must provide a code to be able to change specific environment variables from defaults. Support the development to gain access to a code.

To get access to the image use your container orchestrator to pull from the following locations:

```
ghcr.io/nfrastack/container-bookstack:(image_tag)
docker.io/nfrastack/bookstack:(image_tag)
```

Image tag syntax is:

`<image>:<optional tag>-<optional phpversion>`

Example:

`docker.io/nfrastack/container-bookstack:latest` or

`ghcr.io/nfrastack/container-bookstack:1.0-php84`

* `latest` will be the most recent commit

* An optional `tag` may exist that matches the [CHANGELOG](CHANGELOG.md) - These are the safest


Have a look at the container registries and see what tags are available.

#### Multi-Architecture Support

Images are built for `amd64` by default, with optional support for `arm64` and other architectures.

### Quick Start

* The quickest way to get started is using [docker-compose](https://docs.docker.com/compose/). See the examples folder for a working [compose.yml](examples/compose.yml) that can be modified for your use.

* Map [persistent storage](#persistent-storage) for access to configuration and data files for backup.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image.

**The first boot can take from 2 minutes - 5 minutes depending on your CPU to setup the proper schemas.**

### Persistent Storage

The following directories/files should be mapped for persistent storage in order to utilize the container effectively.

| Directory        | Description                                                                  |
| ---------------- | ---------------------------------------------------------------------------- |
| `/logs`          | Nginx and PHP Log files                                                      |
| `/www/bookstack` | (Optional) If you want to expose the bookstack sourcecode expose this volume |
| **OR**           |                                                                              |
| `/data`          | Hold onto your persistent sessions and cache between container restarts      |


### Environment Variables

#### Base Images used

| Image                                                                 | Description         |
| --------------------------------------------------------------------- | ------------------- |
| [OS Base](https://github.com/nfrastack/container-base/)               | Base Image          |
| [Nginx](https://github.com/nfrastack/container-nginx/)                | Nginx Webserver     |
| [Nginx PHP-FPM](https://github.com/nfrastack/container-nginx-php-fpm) | PHP-FPM Interpreter |
| [Laravel](https://github.com/nfrastack/container-laravel)             | Laravel Addon       |

* Variables showing an 'x' under the `Advanced` column can only be set if the containers advanced functionality is enabled.

#### Core Configuration

| Parameter            | Description                                                                                                          | Default                 | `_FILE` |
| -------------------- | -------------------------------------------------------------------------------------------------------------------- | ----------------------- | ------- |
| `SETUP_TYPE`         | `AUTO`matically generate configuration files, run migrations add users. `MANUAL` does nothing                        | `AUTO`                  |         |
| `ADMIN_NAME`         | Full name of the bootstrap admin user (created on a fresh DB only)                                                   | `BookStack Admin`       | x       |
| `ADMIN_EMAIL`        | Email of the bootstrap admin user                                                                                    | `admin@example.com`     | x       |
| `ADMIN_PASS`         | Password of the bootstrap admin user                                                                                 | `bookstack`             | x       |
| `ENABLE_AUTO_UPDATE` | Auto-upgrade BookStack source on container restart when image version differs from `${DATA_PATH}/.bookstack-version` | `TRUE`                  |         |
| `DATA_PATH`          | Base persistent-data path (uploads, themes, version marker live under here)                                          | `/data`                 |         |
| `UPLOADS_PATH`       | BookStack `public/uploads/` redirect target (only used when ENABLE_STORAGE_REDIRECTION=TRUE)                         | `${DATA_PATH}/uploads/` |         |
| `THEMES_PATH`        | BookStack `themes/` redirect target (only used when `MAP_THEMES=TRUE`)                                               | `${DATA_PATH}/themes/`  |         |

#### Database

| Parameter | Description                                                             | Default | `_FILE` |
| --------- | ----------------------------------------------------------------------- | ------- | ------- |
| `DB_HOST` | Hostname or container name of the database server (e.g. `bookstack-db`) |         | x       |
| `DB_PORT` | DB port                                                                 | `3306`  | x       |
| `DB_NAME` | Database name (written to `.env` as `DB_DATABASE`)                      |         | x       |
| `DB_USER` | Database username (written to `.env` as `DB_USERNAME`)                  |         | x       |
| `DB_PASS` | Database password (written to `.env` as `DB_PASSWORD`)                  |         | x       |
| `DB_SSL`  | Enable SSL connectivity `TRUE` `FALSE` or unset                         |         |         |

#### Application

| Parameter         | Description                                                                     | Default | Alias             | `_FILE` |
| ----------------- | ------------------------------------------------------------------------------- | ------- | ----------------- | ------- |
| `APP_URL`         | Full external URL of the site (e.g. `https://bookstack.example.com`). Required. |         | `SITE_URL`        |         |
| `STORAGE_TYPE`    | Filesystem driver: `local` (default), `local_secure`, `s3` or `minio`           | `local` |                   |         |
| `MAIL_DRIVER`     | Mail transport: `smtp` or `sendmail`                                            |         |                   |         |
| `MAIL_HOST`       | SMTP host                                                                       |         | `SMTP_HOST`       |         |
| `MAIL_PORT`       | SMTP port                                                                       |         | `SMTP_PORT`       |         |
| `MAIL_FROM`       | Envelope from-address                                                           |         |                   |         |
| `MAIL_FROM_NAME`  | Envelope from-name                                                              |         |                   |         |
| `MAIL_USERNAME`   | SMTP auth username                                                              |         | `SMTP_USER`       | x       |
| `MAIL_PASSWORD`   | SMTP auth password                                                              |         | `SMTP_PASS`       | x       |
| `MAIL_ENCRYPTION` | SMTP encryption: `tls`, `ssl`, or `null`                                        |         | `SMTP_ENCRYPTION` |         |

* BookStack docs: <https://www.bookstackapp.com/docs/>

#### Setting Arbitrary BookStack Keys

For any other BookStack `.env` key (the full reference lives in `/www/bookstack/.env.example.complete` inside the running container), set `BOOKSTACK_<KEY>=value`

```yaml
environment:
  - BOOKSTACK_APP_DISPLAY_TIMEZONE=America/Vancouver
  - BOOKSTACK_MAIL_VERIFY_SSL=true
  - BOOKSTACK_ALLOW_UNTRUSTED_SERVER_FETCHING=false
  - BOOKSTACK_EXPORT_PAGE_SIZE=letter
  - BOOKSTACK_APP_CONTENT_FILTERING=jfha
```

becomes the following lines in `/www/bookstack/.env`:

```dotenv
APP_DISPLAY_TIMEZONE=America/Vancouver
MAIL_VERIFY_SSL=true
ALLOW_UNTRUSTED_SERVER_FETCHING=false
EXPORT_PAGE_SIZE=letter
APP_CONTENT_FILTERING=jfha
```

>> Use unset, empty string or null to clear a variable defined in config

#### Image Optimization

This is an out of vendor addon that schedules a routine to optimize any png or jp(e)g files that hav been uploaded at a specific time and interval to cut down on storage size.

| Parameter                  | Description                                                      | Default | `_FILE` |
| -------------------------- | ---------------------------------------------------------------- | ------- | ------- |
| `ENABLE_OPTIMIZE_IMAGES`   | Enable automatic image optimizations using optipng and jpegoptim | `TRUE`  |         |
| `OPTIMIZE_IMAGES_BEGIN`    | When to start image optimization use military time HHMM          | `0300`  |         |
| `OPTIMIZE_IMAGES_INTERVAL` | How often to perform image optimization in minutes               | `1440`  |         |

#### Single Sign On Settings

This is an out of vendor addon that allows for logging into a BookStack instance by sending a header value to the application. The user must already exist in the user tables to allow this sort of automatic login.

| Parameter          | Description                                                                              | Default | `_FILE` |
| ------------------ | ---------------------------------------------------------------------------------------- | ------- | ------- |
| `ENABLE_SSO`       | Enable the header-SSO writer. When TRUE, `APP_SSO_KEY` + `APP_SSO_DISCOVER` are required | `FALSE` |         |
| `APP_SSO_KEY`      | Request header name carrying the authenticated identity (e.g. `Remote-User`)             |         | x       |
| `APP_SSO_DISCOVER` | User attribute the header value represents (e.g. `email`, `username`)                    |         | x       |

When `ENABLE_SSO=TRUE` the image writes both keys into `.env` and validates that they're set.

#### LDAP Scheduled Sync

This is an out of vendor addon that allows for synchronizing LDAP users. It relies on existing BookStack LDAP environment variables and settings however adds the following. The user must already exist in the user tables to allow this sort of automatic login.

| Parameter                         | Description                                             | Default          |
| --------------------------------- | ------------------------------------------------------- | ---------------- |
| `ENABLE_LDAP_SYNC_USER`           | Enable scheduled sync of LDAP user list                 | `FALSE`          |
| `LDAP_SYNC_BEGIN`                 | First-fire timing: `+N` minutes from boot, or `HHMM`    | `+0` (immediate) |
| `LDAP_SYNC_INTERVAL`              | Minutes between syncs                                   | `60`             |
| `LDAP_SYNC_USER_FILTER`           | Filter for syncing users from LDAP                      |                  |
| `LDAP_SYNC_USER_RECURSIVE_GROUPS` | Recursively search through LDAP Groups                  |                  |
| `LDAP_SYNC_EXCLUDE_EMAIL`         | Comma seperated values of emails to ignore when syncing |                  |

* * *

## Maintenance

### Shell Access

For debugging and maintenance, `bash` and `sh` are available in the container.

## Support & Maintenance

* For community help, tips, and community discussions, visit the [Discussions board](/discussions).
* For personalized support or a support agreement, see [Nfrastack Support](https://nfrastack.com/).
* To report bugs, submit a [Bug Report](issues/new). Usage questions will be closed as not-a-bug.
* Feature requests are welcome, but not guaranteed. For prioritized development, consider a support agreement.
* Updates are best-effort, with priority given to active production use and support agreements.

## References

* <https://www.bookstackapp.com/docs>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
