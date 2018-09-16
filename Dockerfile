
FROM golang:1-alpine as builder

ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_TYPE
ARG GOCARBON_VERSION

ENV \
  GOPATH=/opt/go

# ---------------------------------------------------------------------------------------

RUN \
  apk update  --quiet --no-cache && \
  apk upgrade --quiet --no-cache && \
  apk add     --quiet \
    g++ git make musl-dev && \
  echo "export BUILD_DATE=${BUILD_DATE}"  > /etc/profile.d/go-carbon.sh && \
  echo "export BUILD_TYPE=${BUILD_TYPE}" >> /etc/profile.d/go-carbon.sh && \
  echo "export VERSION=${VERSION}"       >> /etc/profile.d/go-carbon.sh

RUN \
  mkdir -p \
    ${GOPATH} \
    /var/log/go-carbon && \
  cd ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  git clone https://github.com/lomik/go-carbon.git

RUN \
  cd ${GOPATH} && \
  export PATH="${PATH}:${GOPATH}/bin" && \
  cd go-carbon && \
  if [ "${BUILD_TYPE}" == "stable" ] ; then \
    echo "switch to stable Tag v${GOCARBON_VERSION}" && \
    git checkout tags/v${GOCARBON_VERSION} 2> /dev/null ; \
  fi && \
  version=$(git describe --tags --always | sed 's/^v//') && \
  echo "build version: ${version}" && \
  make

RUN \
  mkdir -p /go-carbon/etc && \
  mv ${GOPATH}/go-carbon/go-carbon                       /go-carbon/go-carbon && \
  mv ${GOPATH}/go-carbon/deploy/go-carbon.conf           /go-carbon/etc/go-carbon.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-schemas.conf     /go-carbon/etc/go-carbon_storage-schemas.conf && \
  mv ${GOPATH}/go-carbon/deploy/storage-aggregation.conf /go-carbon/etc/go-carbon_storage-aggregation.conf

CMD [ "/bin/bash" ]

# ---------------------------------------------------------------------------------------

FROM alpine:3.8

ENV \
  TZ='Europe/Berlin'

EXPOSE 2003 2003/udp 2004 7002 7003 7007 8080

# ---------------------------------------------------------------------------------------

RUN \
  apk update --quiet --no-cache && \
  apk add    --quiet --no-cache --virtual .build-deps \
    shadow tzdata && \
  cp /usr/share/zoneinfo/${TZ} /etc/localtime && \
  echo ${TZ} > /etc/timezone && \
  /usr/sbin/useradd --system -U -s /bin/false -c "User for Graphite daemon" carbon && \
  mkdir /var/log/go-carbon && \
  apk del --quiet --purge .build-deps && \
  rm -rf \
    /tmp/* \
    /var/cache/apk/*

COPY --from=builder /etc/profile.d/go-carbon.sh  /etc/profile.d/go-carbon.sh
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

LABEL \
  version="${BUILD_TYPE}" \
  maintainer="Bodo Schulz <bodo@boone-schulz.de>" \
  org.label-schema.build-date=${BUILD_DATE} \
  org.label-schema.name="go carbon Docker Image" \
  org.label-schema.description="Inofficial go carbon Docker Image" \
  org.label-schema.url="https://github.com/lomik/go-carbon" \
  org.label-schema.vcs-url="https://github.com/bodsch/docker-go-carbon" \
  org.label-schema.vendor="Bodo Schulz" \
  org.label-schema.version=${GOCARBON_VERSION} \
  org.label-schema.schema-version="1.0" \
  com.microscaling.docker.dockerfile="/Dockerfile" \
  com.microscaling.license="The Unlicense"

# ---------------------------------------------------------------------------------------
