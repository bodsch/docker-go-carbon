
FROM alpine:latest

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1702-02"

EXPOSE 2003 2003/udp 2004 7002 7007

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="v3.5" \
  TERM=xterm \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

# ---------------------------------------------------------------------------------------

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    go \
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
    go \
    git && \
  rm -rf \
    ${GOPATH} \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

CMD [ "/opt/startup.sh" ]

# ---------------------------------------------------------------------------------------
