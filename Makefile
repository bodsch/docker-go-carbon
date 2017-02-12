
CONTAINER  := go-carbon
IMAGE_NAME := docker-go-carbon

DATA_DIR   := /tmp/docker-data

build:
	docker \
		build \
		--rm --tag=$(IMAGE_NAME) .
	@echo Image tag: ${IMAGE_NAME}

clean:
	docker \
		rmi \
		${IMAGE_NAME}

run:
	docker \
		run \
		--detach \
		--interactive \
		--tty \
		--publish=2003:2003 \
		--publish=2003:2003/udp \
		--publish=2004:2004 \
		--publish=7002:7002 \
		--publish=7007:7007 \
		--volume=${DATA_DIR}:/srv \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME)

shell:
	docker \
		run \
		--rm \
		--interactive \
		--tty \
		--publish=2003:2003 \
		--publish=2003:2003/udp \
		--publish=2004:2004 \
		--publish=7002:7002 \
		--publish=7007:7007 \
		--volume=${DATA_DIR}:/srv \
		--hostname=${CONTAINER} \
		--name=${CONTAINER} \
		$(IMAGE_NAME) \
		/bin/sh

exec:
	docker exec \
		--interactive \
		--tty \
		${CONTAINER} \
		/bin/sh

stop:
	docker \
		kill ${CONTAINER}

history:
	docker \
		history ${IMAGE_NAME}

