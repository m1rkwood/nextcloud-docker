# Nextcloud via docker

## Choose your Setup

This is a setup for nextcloud via docker.
It has multiple configurations available:
All configurations use Redis and MariaDB. The difference is how they handle SSL and reverse-proxy.

- `nginx_proxy`: the setup handles SSL certificates through letsencrypt and a nginx reverse proxy.
- `self_signed`: easier setup available with self-signed certificate. Though with self-signed certificates, most sync features won't work (i.e. syncing calendars, contacts to your phone)
- `traefik`: uses traefik for routing, easier to add other services on top.
- `traefik_postgres`: same, but with postgreSQL as a database.

Choose the one you are the most comfortable with. Each folder has its own `README.md` file to install its specific case.
If you choose the `traefik` or `traefik_postgres` version, you will have to also install the `traefik-docker` project available [here](https://github.com/m1rkwood/traefik-docker).

Note: on smaller instances, I found postgreSQL to be more reliable, doesn't time out as much, doesn't go out of memory as much.

## Setup your DNS

If you're using the `self_signed` option, you just need to point `@` to your IP, this setup currently doesn't support a subdomain.

Setup your subdomain so that when you're ready, it's already pointing to the right direction. Simply go to your DNS provider, and create a `A` record with the information needed:

```
Type: A Record
Host: cloud
Value: IP-OF-YOUR-SERVER
TTL:
```

For `Host`, choose whatever subdomain you want to host at.
For `TTL`, I used the lowest available or `Automatic`

## Useful commands while maintenaing Nextcloud

### Backup & Restore the database

backup your database (mariaDB)
```
docker exec <CONTAINER_NAME_OR_ID> /usr/bin/mysqldump -u <MYSQL_USER> --password=<MYSQL_PASSWORD> <DATABASE_NAME> > nextcloud_backup.sql
```
backup your database (postgreSQL)
```
docker exec <CONTAINER_NAME_OR_ID> pg_dump -U <POSTGRES_USER> <DATABASE_NAME> > nextcloud_backup.sql
```
backup all databases (postgreSQL, recommended)
```
docker exec <CONTAINER_NAME_OR_ID> pg_dumpall -U <POSTGRES_USER> > nextcloud_backup.sql
```
restore your database (mariaDB)
```
cat nextcloud_backup.sql | docker exec -i <CONTAINER_NAME_OR_ID> /usr/bin/mysql -u <MYSQL_USER> --password=<MYSQL_PASSWORD> <DATABASE_NAME>
```
restore your database (postgreSQL)
```
cat nextcloud_backup.sql | docker exec -i <CONTAINER_NAME_OR_ID> psql -U <POSTGRES_USER> <DATABASE_NAME>
```
restore all databases (postgreSQL, recommended)
```
cat nextcloud_backup.sql | docker exec -i <CONTAINER_NAME_OR_ID> psql -U <POSTGRES_USER>
```

### Backup the database automatically

You can add a cronjob to backup your database regularly.
On the host server, run `crontab -u <username> -e` and add the following:

MariaDB:
```
0 8 * * 1 docker exec <CONTAINER_NAME_OR_ID> /usr/bin/mysqldump -u <MYSQL_USER> --password="<MYSQL_PASSWORD>" <DATABASE_NAME> > <PATH_TO_BACKUPS>/backup_`date +%Y%m%d%H%M%S`.sql
```
PostgreSQL:
```
0 8 * * 1 docker exec <CONTAINER_NAME_OR_ID> pg_dump -U <POSTGRES_USER> <DATABASE_NAME> > <PATH_TO_BACKUPS>/backup_`date +%Y%m%d%H%M%S`.sql
```
PostgreSQL (backup all databases, recommended):
```
0 8 * * 1 docker exec <CONTAINER_NAME_OR_ID> pg_dumpall -U <POSTGRES_USER> > <PATH_TO_BACKUPS>/backup_`date +%Y%m%d%H%M%S`.sql
```
This one runs every Monday at 8am, you can change it at your convenience.

Bonus: delete backups that are older than 30 days (runs everyday at 12am)
```
0 0 * * * find <PATH_TO_BACKUPS> -name "backup_*.sql" -type f -mtime +30 -delete
```

### PostgreSQL upgrade
When moving to a new major version of PostgreSQL, you might have following error when restarting the containers:
```
FATAL: database files are incompatible with server
DETAIL: The data directory was initialized by PostgreSQL version X, which is not compatible with this version X
```
In that case, you will need to do the following:
- Stop all the containers `docker-compose down`
- If you were using the latest image `postgres:alpine`, you will have to modify the `docker-compose.yml` file with the image of the version of PostgreSQL you were using before the upgrade, i.e. `postgres:13-alpine` for postgres 13.
- Start the postgres container `docker-compose up -d postgres`
- Backup all databases as described previously
- Stop the container `docker-compose down`
- Delete the database volume `docker-compose volume rm <VOLUME_NAME_OR_ID>`
- Modify the `docker-compose.yml` file with the image of the version of PostgreSQL you wish to use, i.e. `postgres:alpine` for latest
- Start the postgres container `docker-compose up -d postgres`
- Restore your backup as described previously (restore all databases)

After that, you should be able to start all containers safely.

### Open a Docker console

```
$ docker exec -it <CONTAINER_NAME_OR_ID> bash
```

To find the id or name of your container

```
$ docker ps
```

### Photos & Thumbnails
#### Install Preview Generator
In the admin of Nextcloud, install the app `Preview Generator`

#### Install packages for Video Support
Videos don't show thumbnails by default in Nextcloud. Here's how to fix it

Skip this step if you're using my Dockerfile, these packages will be installed by default.

```
$ apt-get update
$ apt install -y ffmpeg imagemagick ghostscript
```

#### Modify config.php file

Add these values to the `app/config/config.php`

```
'enabledPreviewProviders' =>
  array (
    0 => 'OC\\Preview\\TXT',
    1 => 'OC\\Preview\\MarkDown',
    2 => 'OC\\Preview\\OpenDocument',
    3 => 'OC\\Preview\\PDF',
    4 => 'OC\\Preview\\MSOffice2003',
    5 => 'OC\\Preview\\MSOfficeDoc',
    6 => 'OC\\Preview\\HEIC',
    7 => 'OC\\Preview\\Image',
    8 => 'OC\\Preview\\Photoshop',
    9 => 'OC\\Preview\\TIFF',
   10 => 'OC\\Preview\\SVG',
   11 => 'OC\\Preview\\Font',
   12 => 'OC\\Preview\\MP3',
   13 => 'OC\\Preview\\Movie',
   14 => 'OC\\Preview\\MKV',
   15 => 'OC\\Preview\\MP4',
   16 => 'OC\\Preview\\AVI',
  ),
'preview_max_x' => '2048',
'preview_max_y' => '2048',
'jpeg_quality' => '60',
```

Note: previews will take a lot of space after some time, so you can also lower `preview_max_x` & `preview_max_y` to something like `512`.

#### Modify thumbnail sizes
Default sizes for `previewgenerator` are ok but they're going to take space over time, so I changed their default size. It's also improving the gallery performance overall.

```
docker exec -it <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ config:app:set --value="32 256" previewgenerator squareSizes
```

```
docker exec -it <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ config:app:set --value="256 384" previewgenerator widthSizes
```

```
docker exec -it <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ config:app:set --value="256" previewgenerator heightSizes
```

If you want to regenerate all previews after some time, delete the `app/data/appdata_xxxxx/preview` folder, then run this command so that nextcloud knows they've been deleted:
```
docker exec -it <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ files:scan-app-data
```
Then regenerate all the previews (see below)

#### Generate the Previews & Setup the cronjob

Then on the host server, run this command to generate all previews once you're finished configuring the previews.

```
docker exec -it <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ preview:generate-all -vvv
```

Still on the host server, add a cronjob

```
crontab -u <username> -e
```

```
*/30 * * * * docker exec <CONTAINER_NAME_OR_ID> sudo -u www-data php /var/www/html/occ preview:pre-generate
```

#### Ordering Photos
When uploading directly through the desktop app, your photos might be out of order because Nextcloud doesn't read `EXIF` formats. Instead it takes into consideration the Created & Modified dates of a picture.

Before uploading your pictures to Nextcloud, you can change their Created & Modified dates based on `EXIF` data. Install the command line tool `exiftool` and run this in the folder you want to upload (this will also work for .MOV files).
```
exiftool "-filecreatedate<datetimeoriginal" . && exiftool "-FileCreateDate<CreateDate" -ext Mov . && exiftool "-FileModifyDate<datetimeoriginal" . && exiftool "-FileModifyDate<CreateDate" -ext Mov .
```
To do it recursively
```
find . -type d -exec exiftool "-filecreatedate<datetimeoriginal" \{\} \; && find . -type d -exec exiftool "-FileCreateDate<CreateDate" -ext Mov \{\} \; && find . -type d -exec exiftool "-FileModifyDate<datetimeoriginal" \{\} \; && find . -type d -exec exiftool "-FileModifyDate<CreateDate" -ext Mov \{\} \;
```

### Update Nextcloud

#### Update your containers

- To stop your containers, run `docker-compose down`
- To start your containers, run `docker-compose up -d`
- If you want to make changes to the `docker-compose.yml`, starting it again will apply the new configuration
- To update your containers, run `docker-compose pull` and then `docker-compose up -d`. If you have built an image with a Dockerfile, `docker-compose pull` will fail to pull it. Just run `docker-compose build --pull` before running `docker-compose up -d`.
- To check the status of your containers, run `docker-compose ps`.
- Persistent data (your Nextcloud data and database) are in the app subfolders and in the database volume (if you decided to go with that option). All your data is safe when you stop/remove/recreate your containers.
- If you want to test around and delete/recreate your containers and volume often, don't delete the proxy data, as letsencrypt might block the generation of a SSL certificate for up to a week if you attempt to much.

#### Clean/remove images, containers

- To clean your images and container, you can use `docker image prune` and `docker container prune`. You can also remove your volumes with `docker volume prune`, but you will lose all your data!

### Scan new files on the server

If you happen to add files directly on the server and want to see them in your Nextcloud instance, add them to your files at `app/data/<USERNAME>/files/`

Navigate to the new folder and add the proper permissions to the files
```
sudo chown -R www-data:www-data </path/to/nextcloud/data/>
```

Then make Nextcloud scan the new files
```
docker exec -i <CONTAINER_NAME_OR_ID> sudo -u www-data /var/www/html/occ files:scan <username>
```

### Setup cronjobs

If you want to set cronjobs on your instance instead of using AJAX, here's the simpliest way I've found:

On the host server, run

```
crontab -u <username> -e
```

Than paste to the end of the file and save

```
*/5 * * * * docker exec <CONTAINER_NAME_OR_ID> sudo -u www-data php -f /var/www/html/cron.php
```

Verify that your cron is showing

```
crontab -u <username> -l
```

### Resync birthday calendar

I tested importing/exporting my calendars & contacts to Nextcloud and this resulted in showing multiple events for birthdays. You can fix it by resyncing the birthday calendar:
First, open a docker console

```
docker exec -it nextcloud bash
```

then

```
sudo -u www-data php occ dav:sync-birthday-calendar
```

I found other useful commands here:
`https://docs.nextcloud.com/server/10.0/admin_manual/configuration_server/occ_command.html#dav-label`

### Backup your contacts & calendars

#### Contacts

```
curl -u <username:password> https://<url>/remote.php/dav/addressbooks/users/<username>/contacts?export
```

#### Calendars

```
curl -u <username:password> https://<url>/remote.php/dav/calendars/<username>/<calendar_name>?export -o calendar.ics
```

### Troubleshooting

If you get this kind of error while running `occ` commands or cronjobs:
```
Fatal error: Allowed memory size of 2097152 bytes exhausted
```
Add this to your commands after `php`
```
-d memory_limit=-1
```
