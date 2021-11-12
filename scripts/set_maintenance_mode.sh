#! /bin/bash

# set nextcloud maintenance mode to on/off
MAINTENANCE_MODE=$1

if [ ! -z "$MAINTENANCE_MODE" ]; then
    if [ $MAINTENANCE_MODE = "on" ]; then
      docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ maintenance:mode --on
    fi

    if [ $MAINTENANCE_MODE = "off" ]; then
      docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ maintenance:mode --off
    fi
else
    echo '[!] Missing maintenance mode (on/off) as argument'
fi