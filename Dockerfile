
FROM golang:1.10-alpine as builder

ENV \
  TERM=xterm \
  TZ='Europe/Berlin' \
  BUILD_DATE="2018-05-04" \
  BUILD_TYPE="stable" \
  VERSION="0.12.0"

# ---------------------------------------------------------------------------------------

RUN \
  apk update --no-cache && \
  apk upgrade --no-cache && \
  apk add \
    g++ git make musl-dev && \
  echo "export BUILD_DATE=${BUILD_DATE}" >> /etc/enviroment && \
  echo "export BUILD_TYPE=${BUILD_TYPE}" >> /etc/enviroment && \
  echo "export VERSION=${VERSION}" >> /etc/enviroment

RUN \
  export GOPATH=/opt/go && \
  mkdir -p \
    ${GOPATH} \
    /var/log/go-carbon && \
  cd ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/lomik/go-carbon.git

RUN \
  export GOPATH=/opt/go && \
  cd ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  cd go-carbon && \
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${VERSION}" && \
    git checkout tags/v${VERSION} 2> /dev/null ; \
  fi && \
  version=$(git describe --tags --always | sed 's/^v//') && \
  echo "build version: ${version}" && \
  make

RUN \
  export GOPATH=/opt/go && \
  mkdir -p /go-carbon/etc && \
  mv ${GOPATH}/go-carbon/go-carbon /go-carbon/go-carbon && \
  mv ${GOPATH}/go-carbon/deploy/go-carbon.conf           /go-carbon/etc/go-carbon.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-schemas.conf     /go-carbon/etc/go-carbon_storage-schemas.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-aggregation.conf /go-carbon/etc/go-carbon_storage-aggregation.conf

CMD [ "/bin/bash" ]

# ---------------------------------------------------------------------------------------

FROM alpine:3.7

ENV \
  TZ='Europe/Berlin'

EXPOSE 2003 2003/udp 2004 7002 7003 7007 8080

LABEL \
  version="1805" \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
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
  if [ -f /etc/enviroment ] ; then . /etc/enviroment; fi && \
  apk add --no-cache --quiet --virtual .build-deps \
    shadow tzdata && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo ${TZ} > /etc/timezone && \
  /usr/sbin/useradd --system -U -s /bin/false -c "User for Graphite daemon" carbon && \
  mkdir /var/log/go-carbon && \
  apk del --quiet --purge .build-deps && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

COPY --from=builder /etc/enviroment /etc/enviroment
COPY --from=builder /go-carbon/etc  /etc/go-carbon/
COPY --from=builder /go-carbon/go-carbon /usr/bin/go-carbon

COPY rootfs/ /

WORKDIR /

VOLUME /srv

HEALTHCHECK \
  --interval=5s \
  --timeout=2s \
  --retries=12 \
  CMD ps ax | grep -v grep | grep -c go-carbon || exit 1

CMD [ "/init/run.sh" ]

# ---------------------------------------------------------------------------------------
