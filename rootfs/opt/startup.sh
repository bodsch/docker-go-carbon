#!/bin/sh
#

WORK_DIR=${WORK_DIR:-/srv}

CONFIG_FILE="/etc/carbon.conf"

prepare() {

  sed -i \
    -e 's|%DATA_DIR%|'${WORK_DIR}'|g' \
    ${CONFIG_FILE}

  dataDirectory=$(grep 'data-dir' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')
  schemasFile=$(grep 'schemas-file' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')

  [ -d ${dataDirectory} ] || mkdir -p ${dataDirectory}

  cp  /etc/go-carbon.schemas ${schemasFile}
}


run() {

  prepare

  go-carbon -check-config -config ${CONFIG_FILE}

  go-carbon -config ${CONFIG_FILE}
}

run

# EOF
