# Run NextCloud in Docker Compose

Some scripts to run NextCloud with Docker Compose.

## Installing

First, clone the repository:

```bash
git clone https://github.com/luxas/nextcloud
cd nextcloud
```

Create the `./data` folder, and mount it to some kind of persistent storage:

```bash
mkdir data
mount /dev/sdXN $(pwd)/data
```

Either, create a TLS cert-keypair from e.g. Let's Encrypt, or run `make self-sign-cert` to `secret/nextcloud.{crt,key}`

Populate the `./DOMAIN` file with the domain your NextCloud instance will be accessible on.

```bash
echo "<your-domain-here>" > DOMAIN
```

Lastly, run `make up`:

```bash
make up
```

### Upgrading

Upgrading "should" be as easy as bumping the version variables in the Makefile, and running `make up` again.

### Helper methods

```bash
# Show the current Docker Compose config
make config

# Show the logs of the containers
make logs

# Exec into the nextcloud container as the www-data user, to be able to run occ commands
make exec

# Stop all the containers
make down
```

## Install the NextCloud Client on Ubuntu

```bash
sudo add-apt-repository ppa:nextcloud-devs/client
sudo apt-get update
sudo apt-get install -y nextcloud-client
```
