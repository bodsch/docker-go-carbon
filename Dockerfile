
FROM alpine:3.7

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

ENV \
  TERM=xterm \
  BUILD_DATE="2017-12-06" \
  BUILD_TYPE="stable" \
  VERSION="0.11.0" \
  GOPATH=/opt/go

EXPOSE 2003 2003/udp 2004 7002 7003 7007 8080

LABEL \
  version="1712" \
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

RUN \
  apk update --no-cache --quiet && \
  apk upgrade --no-cache --quiet && \
  apk add --no-cache --quiet --virtual .build-deps \
    g++ git go make musl-dev shadow && \
  mkdir -p \
    ${GOPATH} \
    /var/log/go-carbon && \
  /usr/sbin/useradd --system -U -s /bin/false -c "User for Graphite daemon" carbon && \
  cd ${GOPATH} && \
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
  install -m 0755 ${GOPATH}/go-carbon/go-carbon /usr/bin/go-carbon && \
  mv ${GOPATH}/go-carbon/deploy/go-carbon.conf           /etc/go-carbon.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-schemas.conf     /etc/go-carbon_storage-schemas.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-aggregation.conf /etc/go-carbon_storage-aggregation.conf && \
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

WORKDIR /

VOLUME /srv

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  CMD ps ax | grep -c go-carbon || exit 1

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------
