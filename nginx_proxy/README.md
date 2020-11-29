# Nginx Proxy Setup
## Folder Structure
On your server, you should have the following structure.
You can create this structure in the `/home/nexcloud`, or `/root/nexcloud` depending on your server.
```
app/
config/
    uploadsize.conf
proxy/
.env
docker-compose.yml
Dockerfile
```
## Envionment
Duplicate the `.env.template` and rename it to `.env`
In the `.env` file, add below information.  
```
NEXTCLOUD_ROOT=<DIRECTORY>/app
PROXY_ROOT=<DIRECTORY>/proxy
MYSQL_ROOT_PASSWORD=
MYSQL_PASSWORD=
REDIS_PASSWORD=
VIRTUAL_HOST=
LETSENCRYPT_HOST=
LETSENCRYPT_EMAIL=

```
For `NEXTCLOUD_ROOT` && `PROXY_ROOT`, navigate to your desired folder, and type `pwd` to know its absolute path. Any path will do, as an example, `/home/nextcloud` or `/root/nextcloud` will both work. For the passwords, generate strong passwords.

`VIRTUAL_HOST` and `LETSENCRYPT_HOST` are the domain to be used, i.e. `cloud.domain.com`.  
`LETSENCRYPT_EMAIL` is the email used to generate the SSL certificate.

## Build the image & start the containers
Builds the containers from the `docker-compose.yml` and `Dockerfile`
Always run these commands from the main folder that contains your `docker-compose.yml` file
```
docker-compose build
docker-compose up -d
```
