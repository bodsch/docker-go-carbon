#!/bin/bash
#

if [ ${DEBUG} ]
then
  set -x
fi

WORK_DIR=${WORK_DIR:-/srv}

CONFIG_FILE="/etc/carbon.conf"

prepare() {

  sed -i \
    -e 's|%DATA_DIR%|'${WORK_DIR}'|g' \
    ${CONFIG_FILE}

  dataDirectory=$(grep 'data-dir' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')
  schemasFile=$(grep 'schemas-file' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')

  [ -d ${dataDirectory} ] || mkdir -vp ${dataDirectory}

  cp -v /etc/go-carbon.schemas ${schemasFile}
}

startSupervisor() {

  echo -e "\n Starting Supervisor.\n\n"

  if [ -f /etc/supervisord.conf ]
  then
    /usr/bin/supervisord -c /etc/supervisord.conf >> /dev/null
  else
    exec /bin/bash
  fi
}


run() {

  prepare

  go-carbon -check-config -config /etc/carbon.conf

  echo -e "\n"
  echo " ==================================================================="
  echo " starting go-carbon"
  echo " ==================================================================="
  echo ""

  startSupervisor
}

run

# EOF
