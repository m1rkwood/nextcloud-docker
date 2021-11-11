#! /bin/bash

# 
echo 'This script will regenerate all previews from the Nextcloud Preview Generator App'
echo 'This action can take a lot of time depending of the number of images/videos you host'
echo ''
echo '[?] Do you want to continue [yes/no] ?'
read answer

if [ $answer = "yes" ]; then
  docker exec -it nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ preview:generate-all -vvv
else
  echo '[!] Canceled by user.'
fi
