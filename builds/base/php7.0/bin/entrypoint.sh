#!/bin/bash

if [ ${DEBUG:-0} -ge 1 ]; then
    [[ -f /.dockerenv ]] && echo -e "\033[1mDocker: \033[33m${WF_DOCKER_HOST_CHAIN}\033[0m"
    echo -e "\033[1mDEBUG\033[33m $(realpath "$0")\033[0m"
    SYMFONY_COMMAND_DEBUG="-vvv"
    DOCKER_DEBUG="-e DEBUG=${DEBUG}"
fi
[[ ${DEBUG:-0} -ge 2 ]] && set -x

CHECKFILE="/home/.system.ready"

read -r -d '' HELP <<-EOM

Initialize script:

  -w --wait-for-init [arg]   Waiting for initialize

EOM

function init {
    rm -rf $CHECKFILE

    # CREATE USER
    USER_ID=${LOCAL_USER_ID:-9001}
    export HOME=${LOCAL_USER_HOME}

    LOCALE=${LOCALE:-en_US}

    if [[ $(id -u) == 0 ]]; then
        # Timezone
        ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone
        # Locale
        echo "${LOCALE}.UTF-8 UTF-8" >> /etc/locale.gen && \
           locale-gen ${LOCALE}.UTF-8 && \
           /usr/sbin/update-locale LANG=${LOCALE}.UTF-8 && \
           export LC_ALL=${LOCALE}.UTF-8
        # www-data owner
        chgrp www-data /usr/local/etc/php/conf.d

        echo "Starting with UID : $USER_ID"
        usermod -u $USER_ID --home ${LOCAL_USER_HOME} www-data
        groupmod -g $WWW_DATA_GID www-data

        if [[ $XDEBUG_ENABLED != 1 ]]; then
            # Disable xdebug
            XDEBUG_INI_BASE=`php --ini | grep -oh ".*xdebug.ini"`
            XDEBUG_INI=$([ -h ${XDEBUG_INI_BASE} ] && readlink ${XDEBUG_INI_BASE} || echo ${XDEBUG_INI_BASE})
            sed -i "s/\([^;]*zend_extension=.*xdebug.so\)/;\\1/" $XDEBUG_INI
        else
            # Set remote IP
            HOST_IP=`/sbin/ip route|awk '/default/ { print $3 }'`
            for file in $(egrep -lir --include=xdebug.ini.dist "remote" /usr/local/etc/php); do
                cp $file $(dirname $file)/xdebug.ini
                sed -i "s/\(xdebug.remote_host *= *\).*/\\1${HOST_IP}/" $(dirname $file)/xdebug.ini
            done
        fi

        # The FPM can't use the environment variables for config, so we replace them here
        envsubst < /usr/local/etc/php/conf.d/99-custom.ini.dist > /usr/local/etc/php/conf.d/99-custom.ini

        # PHP-FPM start
        if [[ $CI != 1 && $CI != 'true' ]]; then
            # Symfony envs. Some PHP-FPM doesn't support the empty value (like 5.6), so this grep find only not empty values!
            env | grep ^SYMFONY.*[^=]$ | awk '{split($0,a,"="); print "env[" a[1] "]=" a[2]}' >> /usr/local/etc/php-fpm.d/www.conf
            php-fpm &
            echo "PHP-FPM started: service php-fpm start"
        fi

        touch $CHECKFILE
    fi

    # START BASH
    if [ -z ${DOCKER_USER} ] || [ -z "${@}" ]; then
        ${@:-php -a}
    else
        gosu ${DOCKER_USER} "${@}"
    fi
}

function waitingForStart {
    c=0
    while [ ! -f $CHECKFILE ]; do
        c++ && $c==10 && exit 1;
        echo "Waiting for engine ready"
        sleep 1
    done;
}

case $1 in
    -h|--help)
    echo -e "${HELP}"
    exit 1
    ;;
    # Wait-for init
    -w|--wait-for-init)
    waitingForStart
    ;;
    # Init
    *)
    init ${@}
    ;;
esac
