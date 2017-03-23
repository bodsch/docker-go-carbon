
FROM golang:1.8-alpine

# FROM alpine:latest

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1703-03"

EXPOSE 2003 2003/udp 2004 7002 7007

ENV \
  TERM=xterm \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    git && \
  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get -d github.com/lomik/go-carbon && \
  cd ${GOPATH}/src/github.com/lomik/go-carbon && \
  make submodules && \
  make && \
  install -m 0755 go-carbon /usr/bin/go-carbon && \
  apk del --purge \
    build-base \
    git && \
  rm -rf \
    ${GOPATH} \
    /go \
    /tmp/* \
    /usr/local/go \
    /usr/local/bin/go-wrapper \
    /var/cache/apk/*

COPY rootfs/ /

WORKDIR /

CMD [ "/opt/startup.sh" ]

# ---------------------------------------------------------------------------------------
