export NEXTCLOUD_VERSION=19.0.3
export COLLABORA_VERSION=4.2.6.2
export MARIADB_VERSION=10.5.5
export TRAEFIK_VERSION=1.7.26
IP_ADDRESS:=$(shell ip route | grep "$(shell ip route show default | awk '{print $$5}')" | grep src | awk '{print $$9}')
DOMAIN?=$(shell cat DOMAIN)
REGEXP_DOMAIN?=$(shell cat REGEXP_DOMAIN)
export IP_ADDRESS
export DOMAIN
export REGEXP_DOMAIN
SHELL:=/bin/bash

ifeq ($(DOMAIN),)
$(error DOMAIN is a required value, please populate the DOMAIN file)
endif
ifeq ($(REGEXP_DOMAIN),)
$(error REGEXP_DOMAIN is a required value, please populate the REGEXP_DOMAIN file)
endif

all: up
up: /usr/local/bin/docker-compose secret/nextcloud.crt secret/passwords/mysql_user secret/passwords/mysql_root secret/passwords/nextcloud_admin
	[[ $$(mount | grep $$(pwd)/data) ]] && exit 0 || (echo "You need to mount the $(pwd)/data folder" && exit 1)
	@MYSQL_PASSWORD=$(shell cat secret/passwords/mysql_user) \
	MYSQL_ROOT_PASSWORD=$(shell cat secret/passwords/mysql_user) \
	NEXTCLOUD_ADMIN_PASSWORD=$(shell cat secret/passwords/nextcloud_admin) \
	docker-compose up -d

secret/passwords/%:
	mkdir -p secret
	if [[ ! -f secret/passwords/$* ]]; then cat /dev/urandom | tr -cd 'a-z0-9' | head -c 32 > secret/passwords/$*; fi

postinstall:
	@echo "Performing postinstall tasks:"
	$(MAKE) occ-db:convert-filecache-bigint
	$(MAKE) occ-db:add-missing-indices
	$(MAKE) occ-db:add-missing-columns

occ-%:
	while [[ $$(docker exec -it -u www-data nextcloud_nextcloud_1 ./occ $* --no-interaction >/dev/null 2>/dev/null; echo $$?) != 0 ]]; do sleep 1; done

logs:
	docker-compose logs -f

down config:
	docker-compose $@

exec:
	docker-compose exec -u www-data nextcloud /bin/bash

self-signed-cert:
	mkdir -p certs
	# TODO: Use Let's Encrypt instead.
	openssl req -x509 -nodes -subj '/CN=${DOMAIN}' -newkey rsa:2048 -keyout certs/nextcloud.key -out certs/nextcloud.crt -days 365


/usr/local/bin/docker-compose:
	sudo curl -sSL https://github.com/docker/compose/releases/download/1.23.2/docker-compose-Linux-x86_64 -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
