
FROM bodsch/docker-alpine-base:1701-02

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.2.1"

EXPOSE 2003 2003/udp 2004 7002 7007

ENV \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

# ---------------------------------------------------------------------------------------

RUN \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    go \
    git && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  go get -d github.com/lomik/go-carbon && \
  cd ${GOPATH}/src/github.com/lomik/go-carbon && \
  make submodules && \
  make && \
  install -m 0755 go-carbon /usr/bin/go-carbon && \
  apk del --purge \
    build-base \
    go \
    git \
    wget \
    bash \
    nano \
    tree \
    curl \
    ca-certificates && \
  rm -rf \
    ${GOPATH} \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

CMD [ "/opt/startup.sh" ]

# ---------------------------------------------------------------------------------------
