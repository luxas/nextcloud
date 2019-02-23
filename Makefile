export NEXTCLOUD_VERSION=15.0.4
export MARIADB_VERSION=10.4.2
export TRAEFIK_VERSION=1.7.9
export MYSQL_PASSWORD=$(shell cat data/passwords/mysql_user 2>/dev/null || cat /dev/urandom | tr -cd 'a-z0-9' | head -c 32)
export MYSQL_ROOT_PASSWORD=$(shell cat data/passwords/mysql_root 2>/dev/null || cat /dev/urandom | tr -cd 'a-z0-9' | head -c 32)
export NEXTCLOUD_ADMIN_PASSWORD=$(shell cat data/passwords/nextcloud_admin 2>/dev/null || cat /dev/urandom | tr -cd 'a-z0-9' | head -c 32)
export DOMAIN=
SHELL:=/bin/bash

ifeq ($(DOMAIN),)
$(error DOMAIN is a required value)
endif

all: data/
data/: up
up: /usr/local/bin/docker-compose certs/${DOMAIN}.crt
	mkdir -p data/passwords
	docker-compose up -d
	@if [[ ! -f data/passwords/mysql_user ]]; then echo ${MYSQL_PASSWORD} > data/passwords/mysql_user; fi
	@if [[ ! -f data/passwords/mysql_root ]]; then echo ${MYSQL_ROOT_PASSWORD} > data/passwords/mysql_root; fi
	@if [[ ! -f data/passwords/nextcloud_admin ]]; then echo ${NEXTCLOUD_ADMIN_PASSWORD} > data/passwords/nextcloud_admin; fi

	# Post-install
	# occ db:convert-filecache-bigint
	# occ config:system:set trusted_domains 2 --value ${DOMAIN}

certs/nextcloud.crt:
	mkdir -p certs
	# TODO: Use Let's Encrypt instead.
	openssl req -x509 -nodes -subj '/CN=${DOMAIN}' -newkey rsa:2048 -keyout certs/nextcloud.key -out certs/nextcloud.crt -days 365


/usr/local/bin/docker-compose:
	sudo curl -sSL https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
