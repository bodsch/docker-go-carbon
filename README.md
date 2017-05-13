# docker-go-carbon

A Docker container for the Golang implementation of Graphite/Carbon server with classic architecture:
Agent -> Cache -> Persister (https://github.com/lomik/go-carbon)

# Status

[![Docker Pulls](https://img.shields.io/docker/pulls/bodsch/docker-go-carbon.svg?branch=1705-03)][hub]
[![Image Size](https://images.microbadger.com/badges/image/bodsch/docker-go-carbon.svg?branch=1705-03)][microbadger]
[![Build Status](https://travis-ci.org/bodsch/docker-go-carbon.svg?branch=1705-03)][travis]

[hub]: https://hub.docker.com/r/bodsch/docker-go-carbon/
[microbadger]: https://microbadger.com/images/bodsch/docker-go-carbon
[travis]: https://travis-ci.org/bodsch/docker-go-carbon


# Build

Your can use the included Makefile.

To build the Container: `make build`

To remove the builded Docker Image: `make clean`

Starts the Container: `make run`

Starts the Container with Login Shell: `make shell`

Entering the Container: `make exec`

Stop (but **not kill**): `make stop`

History `make history`


# Docker Hub

You can find the Container also at  [DockerHub](https://hub.docker.com/r/bodsch/docker-go-carbon)

## get

    docker pull bodsch/docker-go-carbon


# supported Environment Vars

# Ports

 - 2003
 - 2003/udp
 - 2004
 - 7002
 - 7007
