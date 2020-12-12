# Nextcloud via docker

## Choose your Setup

This is a setup for nextcloud via docker.  
It has multiple configurations available:  
All configurations use Redis and MariaDB. The difference is how they handle SSL and reverse-proxy.

- `nginx_proxy`: the setup handles SSL certificates through letsencrypt and a nginx reverse proxy.
- `self_signed`: easier setup available with self-signed certificate. Though with self-signed certificates, most sync features won't work (i.e. syncing calendars, contacts to your phone)
- `traefik`: uses traefik for routing, easier to add other services on top.

Choose the one you are the most comfortable with. Each folder has its own `README.md` file to install its specific case.  
If you choose the `traefik` version, you will have to also install the `traefik-docker` project available [here](https://github.com/m1rkwood/traefik-docker).

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

backup your database

```
docker exec <CONTAINER_NAME_OR_ID> /usr/bin/mysqldump -u nextcloud --password=<MYSQL_PASSWORD> <DB_NAME> > nextcloud_backup.sql
```

restore your database

```
cat nextcloud_backup.sql | docker exec -i <CONTAINER_NAME_OR_ID> /usr/bin/mysql -u nextcloud --password=<MYSQL_PASSWORD> <DB_NAME>
```

### Open a Docker console

```
$ docker exec -it <CONTAINER_NAME_OR_ID> bash
```

To find the id or name of your container

```
$ docker ps
```

### Video Thumbnails

Videos don't show thumbnails by default in Nextcloud. Here's how to fix it

#### Install packages

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
    6 => 'OC\\Preview\\PDF',
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

If you happen to add files directly on the server and want to see them in your Nextcloud instance, add them to your files at `app/data/<USERNAME>/files/`, then open the docker console of your nextcloud container and run:

```
sudo -u www-data /var/www/html/occ files:scan <USERNAME>
```

### Setup cronjobs

If you want to set cronjobs on your instance instead of using AJAX, here's the simpliest way I've found:

On the host server, run

```
crontab -u <username> -e
```

Than paste to the end of the file and save

```
*/5 * * * * docker exec <container_name_or_id> sudo -u www-data php -f /var/www/html/cron.php
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
