# Self-signed setup

## Folder structure
```
app/
.env
docker-compose.yml
```

## Envionment
Duplicate the `.env.template` and rename it to `.env`  
In the `.env` file, add below information.  
```
NEXTCLOUD_ROOT=
MYSQL_ROOT_PASSWORD=
MYSQL_PASSWORD=
REDIS_PASSWORD=
```
For `NEXTCLOUD_ROOT`, navigate to your desired folder, and type `pwd` to know its absolute path. Any path will do, as an example, `/home/nextcloud` or `/root/nextcloud` will both work. For the passwords, generate strong passwords.

## Start the container
```
docker-compose build && docker-compose up -d
```
