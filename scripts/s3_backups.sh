#!/bin/bash
# source: https://www.digitalocean.com/community/tutorials/how-to-automate-backups-digitalocean-spaces
DATETIME=`date +%y%m%d-%H_%M_%S`
DST=$1

showHelp() {
    echo 'This script will push your backups to a s3 bucket:'
    echo ''
    echo '- Database backups located at /root/nextcloud-docker/backup/database'
    echo '- Nextcloud config located at /root/nextcloud-docker/traefik_postgres/app/config'
    echo ''
    echo 'Database backups will be uploaded to bucket-name/Nextcloud/Database'
    echo 'Nextcloud config backups will be uploaded to bucket-name/Nextcloud/App'
    echo 'Make sure these folders exist in your bucket'
    echo ''
    echo 's3cmd must be installed on this server: apt install s3cmd && s3cmd --configure'
    echo ''
    echo "If you don't want to upload your backups to s3, just comment the lines starting with s3cmd"
    echo ''
    echo 'To use this script with a cronjob, you can add it to your crontab:'
    echo '- 0 8 * * 1 sh s3_backups.sh'
}

archiveDatabaseBackups() {
    # export the data from nextcloud & compress
    docker exec nextcloud-postgres pg_dumpall -U nextcloud | gzip > /root/nextcloud-docker/backups/database/nextcloud_database_backup_$DATETIME.sql.gz
    # upload the data to s3
    s3cmd put /root/nextcloud-docker/backups/database/nextcloud_database_backup_$DATETIME.sql.gz s3://$DST/Nextcloud/Database/
    # remove backups older than 15 days
    find /root/nextcloud-docker/backups/database -name "*.sql.gz" -type f -mtime +15 -delete
}

archiveNextcloudConfig() {
    # compress the config folder
    tar -czvf /root/nextcloud-docker/backups/app/nextcloud_config_backup_$DATETIME.tar.gz /root/nextcloud-docker/traefik_postgres/app/config
    # upload the data to s3
    s3cmd put /root/nextcloud-docker/backups/app/nextcloud_config_backup_$DATETIME.tar.gz s3://$DST/Nextcloud/App/
    # remove backups older than 15 days
    find /root/nextcloud-docker/backups/app -name "*.tar.gz" -type f -mtime +15 -delete
}

if [ ! -z "$DST" ]; then
    showHelp

    echo '[?] Do you want to continue [yes/no] ?'
    read answer

    if [ $answer = "yes" ]; then
        archiveDatabaseBackups
        archiveNextcloudConfig
    else
        echo '[!] Canceled by user.'
    fi
else
    echo '[!] Missing Destination bucket name as argument'
fi


