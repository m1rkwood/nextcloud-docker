#! /bin/bash

# will rescan all the files, including external storage
docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ files:scan --all