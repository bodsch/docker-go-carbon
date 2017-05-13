
FROM bodsch/docker-golang:1.8

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1705-03"

EXPOSE 2003 2003/udp 2004 7002 7007 8080

ENV \
  ALPINE_MIRROR="dl-cdn.alpinelinux.org" \
  ALPINE_VERSION="edge" \
  TERM=xterm \
  BUILD_DATE="2017-05-13" \
  VERSION="0.9.1" \
  GOPATH=/opt/go \
  GO15VENDOREXPERIMENT=0

LABEL org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="go carbon Docker Image" \
      org.label-schema.description="Inofficial go carbon Docker Image" \
      org.label-schema.url="https://github.com/lomik/go-carbon" \
      org.label-schema.vcs-url="https://github.com/bodsch/docker-go-carbon" \
      org.label-schema.vendor="Bodo Schulz" \
      org.label-schema.version=${VERSION} \
      org.label-schema.schema-version="1.0" \
      com.microscaling.docker.dockerfile="/Dockerfile" \
      com.microscaling.license="The Unlicense"

# ---------------------------------------------------------------------------------------

WORKDIR ${GOPATH}

RUN \
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

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------
