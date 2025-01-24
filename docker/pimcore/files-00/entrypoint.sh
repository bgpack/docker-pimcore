#!/bin/bash

# Override default configuration for xdebug v3.x.
# See: https://xdebug.org/docs/all_settings
cat << EOF > /usr/local/etc/php/conf.d/20-xdebug.ini
# bgp config
xdebug.idekey = PHPSTORM
xdebug.mode = debug
xdebug.start_with_request=yes
xdebug.client_host=host.docker.internal ; or your host's IP on Linux
xdebug.client_port=9003
xdebug.log=/tmp/xdebug.log
EOF

# if XDEBUG_HOST is manually set
HOST="$XDEBUG_HOST"

# OrbStack 
if [ -z "$HOST" ]; then
 HOST=`getent ahostsv4 host.internal | awk 'NR==1{ print $1 }'`
fi

# else if check if is Docker for Mac
if [ -z "$HOST" ]; then
  HOST=`getent hosts docker.for.mac.localhost | awk '{ print $1 }'`
fi

# else get host ip
if [ -z "$HOST" ]; then
  HOST=`/sbin/ip route|awk '/default/ { print $3 }'`
fi

exec docker-php-entrypoint "$@"
