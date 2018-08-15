
include env_make
NS       = bodsch

REPO     = docker-go-carbon
NAME     = go-carbon
INSTANCE = default

BUILD_DATE       := $(shell date +%Y-%m-%d)
BUILD_VERSION    := $(shell date +%y%m)
BUILD_TYPE       ?= stable
GOCARBON_VERSION ?= 0.13.0

.PHONY: build push shell run start stop rm release

default: build

params:
	@echo ""
	@echo " GOCARBON_VERSION : ${GOCARBON_VERSION}"
	@echo " BUILD_DATE       : $(BUILD_DATE)"
	@echo ""

build:	params
	docker build \
		--force-rm \
		--compress \
		--build-arg BUILD_DATE=$(BUILD_DATE) \
		--build-arg BUILD_VERSION=$(BUILD_VERSION) \
		--build-arg BUILD_TYPE=$(BUILD_TYPE) \
		--build-arg GOCARBON_VERSION=${GOCARBON_VERSION} \
		--tag $(NS)/$(REPO):${GOCARBON_VERSION} .

clean:
	docker rmi \
		--force \
		$(NS)/$(REPO):${GOCARBON_VERSION}

history:
	docker history \
		$(NS)/$(REPO):${GOCARBON_VERSION}

push:
	docker push \
		$(NS)/$(REPO):${GOCARBON_VERSION}

shell:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		--interactive \
		--tty \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):${GOCARBON_VERSION} \
		/bin/sh

run:
	docker run \
		--rm \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):${GOCARBON_VERSION}

exec:
	docker exec \
		--interactive \
		--tty \
		$(NAME)-$(INSTANCE) \
		/bin/sh

start:
	docker run \
		--detach \
		--name $(NAME)-$(INSTANCE) \
		$(PORTS) \
		$(VOLUMES) \
		$(ENV) \
		$(NS)/$(REPO):${GOCARBON_VERSION}

stop:
	docker stop \
		$(NAME)-$(INSTANCE)

rm:
	docker rm \
		$(NAME)-$(INSTANCE)

release: build
	make push -e VERSION=${GOCARBON_VERSION}

default: build
