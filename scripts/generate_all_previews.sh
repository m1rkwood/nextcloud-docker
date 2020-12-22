#! /bin/bash

# will regenerate all previews from the Nextcloud Preview Generator App
# useful if your preview cache is not made persistent in docker 
docker exec -it nextcloud sudo -u www-data php /var/www/html/occ preview:generate-all -vvv