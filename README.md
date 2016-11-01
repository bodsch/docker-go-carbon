# docker-go-carbon

A Docker container for the Golang implementation of Graphite/Carbon server with classic architecture: Agent -> Cache -> Persister (https://github.com/lomik/go-carbon)

# Status

[![Build Status](https://travis-ci.org/bodsch/docker-go-carbon.svg?branch=master)](https://travis-ci.org/bodsch/docker-carbon-relay-g)


# Build

Your can use the included Makefile.

To build the Container:
    make build

Starts the Container:
    make run

Starts the Container with Login Shell:
    make shell

Entering the Container:
    make exec

Stop (but **not kill**):
    make stop

History
    make history


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
