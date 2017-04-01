
FROM bodsch/docker-golang:1.8

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1703-04"

EXPOSE 2003 2003/udp 2004 7002 7007

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="v3.5" \
  TERM=xterm \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

# ---------------------------------------------------------------------------------------

WORKDIR ${GOPATH}

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --quiet --no-cache update && \
  apk --quiet --no-cache upgrade && \
  apk --quiet --no-cache add \
    build-base \
    git && \

  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/lomik/go-carbon.git && \
  cd go-carbon && \
  make submodules  && \
  make && \
  install -m 0755 go-carbon /usr/bin/go-carbon && \
  apk --quiet --purge del \
    build-base \
    git && \
  rm -rf \
    ${GOPATH} \
    /usr/lib/go \
    /usr/bin/go \
    /usr/bin/gofmt \
    /tmp/* \
    /var/cache/apk/*

COPY rootfs/ /

CMD [ "/opt/startup.sh" ]

# ---------------------------------------------------------------------------------------
