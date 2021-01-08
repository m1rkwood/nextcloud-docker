# Nextcloud setup

To setup nextcloud with this configuration, you will have to also install the `traefik-docker` project available [here](https://github.com/m1rkwood/traefik-docker).

## Folder structure

```
app/
.env
docker-compose.yml
Dockerfile
```

## Envionment

Duplicate the `.env.template` and rename it to `.env`
In the `.env` file, add below information.

```
NEXTCLOUD_ROOT=<DIRECTORY>/app
SUB_DOMAIN=
DOMAIN_NAME=
POSTGRES_PASSWORD=
REDIS_PASSWORD=
```

For `NEXTCLOUD_ROOT`, navigate to your desired folder, and type `pwd` to know its absolute path. Any path will do, as an example, `/home/nextcloud` or `/root/nextcloud` will both work. For the passwords, generate strong passwords.

`SUB_DOMAIN` is the sub-domain used, i.e. `cloud`  
`DOMAIN_NAME` is the domain used, i.e. `example.com`

## Build the image & start the containers

Before running the container, make sure the external network `web` has been created and the `traefik-docker` container is running (see [traefik-docker documentation here](https://github.com/m1rkwood/traefik-docker)).

Builds the containers from the `docker-compose.yml` and `Dockerfile`
Always run these commands from the main folder that contains your `docker-compose.yml` file

```
docker-compose build
docker-compose up -d
```
