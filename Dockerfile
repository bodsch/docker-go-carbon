
FROM alpine:3.6

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  ALPINE_MIRROR="mirror1.hs-esslingen.de/pub/Mirrors" \
  ALPINE_VERSION="v3.6" \
  TERM=xterm \
  BUILD_DATE="2017-10-26" \
  BUILD_TYPE="stable" \
  VERSION="0.11.0" \
  GOPATH=/opt/go \
  APK_ADD="g++ git go make musl-dev"

EXPOSE 2003 2003/udp 2004 7002 7007 8080

LABEL \
  version="1710" \
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
  apk --no-cache --quiet update && \
  apk --no-cache --quiet upgrade && \
  apk --no-cache --quiet --virtual .build-deps add ${APK_ADD} && \
  mkdir -p ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/lomik/go-carbon.git && \
  cd go-carbon && \
  #
  # build stable packages
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${VERSION}" && \
    git checkout tags/v${VERSION} 2> /dev/null ; \
  fi && \
  #
  version=$(git describe --tags --always | sed 's/^v//') && \
  echo "build version: ${version}" && \
  make submodules  && \
  make && \
  install -m 0755 go-carbon /usr/bin/go-carbon && \
  unset GOROOT_BOOTSTRAP && \
  apk --quiet --purge del .build-deps && \
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
