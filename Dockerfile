
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  TERM=xterm \
  BUILD_DATE="2017-09-15" \
  VERSION="0.11.0-2" \
  GOPATH=/opt/go \
  APK_ADD="g++ git go make musl-dev"

EXPOSE 2003 2003/udp 2004 7002 7007 8080

LABEL \
  version="1709" \
  org.label-schema.build-date=${BUILD_DATE} \
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

WORKDIR /

RUN \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/main"       > /etc/apk/repositories && \
  echo "http://${ALPINE_MIRROR}/alpine/${ALPINE_VERSION}/community" >> /etc/apk/repositories && \
  apk --no-cache update && \
  apk --no-cache upgrade && \
  apk --no-cache add ${APK_ADD} && \
  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/lomik/go-carbon.git && \
  cd go-carbon && \
  version=$(git describe --tags --always | sed 's/^v//') && \
  echo "build version: ${version}" && \
  make submodules  && \
  make && \
  install -m 0755 go-carbon /usr/bin/go-carbon && \
  cp /go-carbon/deploy/go-carbon.conf /etc/carbon.conf-DIST && \
  mkdir -p /var/log/carbon && \
  unset GOROOT_BOOTSTRAP && \
  apk --purge del ${APK_ADD} && \
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
