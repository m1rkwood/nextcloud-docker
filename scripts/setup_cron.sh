
#! /bin/bash
echo 'This script will install following cronjobs for nextcloud:'
echo ''
echo '- Default Nextcloud cron'
echo '- Generate previews'
echo '- Scan Nextcloud files'
echo ''
echo '[?] Do you want to continue [yes/no] ?'
read answer

if [ $answer = "yes" ]; then
    echo 'Creating cron...'

    # write out current crontab
    crontab -l > temp_cron

    echo '# NEXTCLOUD CRONJOBS' >> temp_cron
    echo '*/5 * * * * docker exec nextcloud sudo -u www-data php -d memory_limit=-1 -f /var/www/html/cron.php 1>/dev/null' >> temp_cron
    echo '*/5 * * * * docker exec nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ preview:pre-generate 1>/dev/null' >> temp_cron
    echo '0 1 * * * docker exec nextcloud sudo -u www-data php -d memory_limit=-1 /var/www/html/occ files:scan --all 1>/dev/null' >> temp_cron
    
    # install new cron file && remove
    crontab temp_cron && rm temp_cron

    echo 'Done!'
    echo 'Do `crontab -l` to verify.'
else
   echo '[!] Canceled by user.'
fi