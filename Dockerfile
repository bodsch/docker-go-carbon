
FROM bodsch/docker-alpine-base:1610-02

MAINTAINER Bodo Schulz <bodo@boone-schulz.de>

LABEL version="1.1.0"

EXPOSE 2003
EXPOSE 2004
EXPOSE 7002
EXPOSE 7007

ENV GOPATH=/opt/go
ENV GO15VENDOREXPERIMENT=0

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
  go get github.com/jteeuwen/go-bindata/... && \
  cd ${GOPATH}/src/github.com/lomik/go-carbon && \
  make submodules && \
  make

#  mv carbon-relay-ng /usr/bin && \
#  mkdir -p /var/spool/carbon-relay-ng && \
#  chown nobody: /var/spool/carbon-relay-ng && \

RUN \
  apk del --purge \
    build-base \
    go \
    git

#RUN \
#  rm -rf \
#    ${GOPATH} \
#    /tmp/* \
#    /var/cache/apk/* \
#    /root/.n* \
#    /usr/local/bin/phantomjs

# COPY rootfs/ 

#WORKDIR /usr/share/grafana

# CMD [ "/opt/startup.sh" ]

CMD /bin/bash

# EOF
