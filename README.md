Symfony project images
======================

Abilities:
- clone user
- set timezone and locale
- switch on and off the xdebug
- PHP configuration from ENV

## How to use

You need to edit files outside `builds` directory. In files in the `builds`
directory are generated, you mustn't edit it directly!

The templates are in the `config` directory.

### Generate files

    make -s all

### Build and push

    make -s build-all

This script will build doctrine image and push to hub. It will run long.

### Build only one

Go to conrate build directory and run `make -s build` command.

## Environment variables

| Name | E.g. value | Description |
|:---- |:----- |:---- |
| `WWW_DATA_UID` | `1001` | The current user id |
| `WWW_DATA_GID` | `1001` | The current user group id |
| `TIMEZONE` | `Europe/Budapest` | The timezne what you want to use |
| `LOCALE` | `hu_HU` | The locale value what you want to use |
| `XDEBUG_ENABLED` | `0` or `1` | You can switch on or off the xdebug (default: `0`) |
| `ERROR_LOG_ENABLED` | `0` or `1` | You can switch on or off PHP error log (default: `1`) |
| `PHP_IDE_CONFIG` | `"serverName=Docker"` | The xdebug server config name |
| `CI` | `0` or `1` | You can notify the container, it is running in CI test. Then it don't load the fpm. |
| `PHP_MAX_EXECUTION_TIME` | `30` | php.ini: `max_execution_time` in seconds |
| `PHP_MEMORY_LIMIT` | `128M` | php.ini: `memory_limit` |
| `PHP_UPLOAD_MAX_FILESIZE` | `50M` | php.ini: `upload_max_filesize` |
| `PHP_MAX_FILE_UPLOADS` | `20` | php.ini: `max_file_uploads` |
| `PHP_POST_MAX_SIZE` | `100M` | php.ini: `post_max_size` |
 
## Suggested volumes

| Path | Description |
|:---- |:----- |
| `/var/www` | This is the `WORK_DIR`! Load here the project. |
| `/home/user/.ssh` | Set here your SSH keys from `~/.ssh` |
| `/home/user/.gitconfig` | It is the global `.gitignore` file |
| `/home/user/.composer` | The composer config directory |
| `/usr/local/etc/php/conf.d/99-custom.ini.dist` | You can configure PHP through ENV. The php-fpm can't parse ENV variables, we load it with the `entrypoint` file! |
| `/usr/local/etc/php/conf.d/xdebug.ini.dist` | You can configure PHP xdebug! It doesn't work when you disable it: `XDEBUG_ENABLED=0` |

## Example `docker-compose.yml`

```yaml
version: "3"

services:
    symfony:
        image:  fchris82/symfony:php7.2
        environment:
            - CI
            - WWW_DATA_UID
            - WWW_DATA_GID
            # Timezone
            - TIMEZONE
            # PHP config
            - PHP_MAX_EXECUTION_TIME
            - PHP_MEMORY_LIMIT
            - PHP_UPLOAD_MAX_FILESIZE
            - PHP_MAX_FILE_UPLOADS
            - PHP_POST_MAX_SIZE
            # Symfony parameters
            - SYMFONY_ENV
            - SYMFONY_DEBUG
            - SYMFONY_CLASSLOADER_FILE
            - SYMFONY_HTTP_CACHE
            - SYMFONY_HTTP_CACHE_CLASS
            - SYMFONY_TRUSTED_PROXIES
            - SYMFONY_DEPRECATIONS_HELPER
        volumes:
            # Full project files
            - ".:/var/www"
            # User SSH keys
            - "~/.ssh:/home/user/.ssh:ro"
            # Git config fájl bekötése
            - "~/.gitconfig:/home/user/.gitconfig:ro"
            # Composer cache
            - "~/.composer:/home/user/.composer"
            # Your own xdebug config
            - "~/xdebug.ini:/usr/local/etc/php/conf.d/xdebug.ini.dist:ro"
```
