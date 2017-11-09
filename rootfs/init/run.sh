#!/bin/sh
#

set -e

WORK_DIR="/srv"

CONFIG_FILE="/etc/go-carbon/carbon.conf"
DEFAULT_CONFIG="/etc/go-carbon/carbon-default.conf"

prepare() {

  sed -i \
    -e 's|%DATA_DIR%|'${WORK_DIR}'|g' \
    -e 's|/var/lib|'${WORK_DIR}'|g' \
    -e 's|127.0.0.1:|:|g' \
    ${CONFIG_FILE}

  data_directory=$(grep '^data-dir' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')
  schemas_file=$(grep '^schemas-file' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')
  aggregation_file=$(grep '^aggregation-file' ${CONFIG_FILE} | awk -F ' = ' '{printf $2}' | sed -e 's|"||g')

#  echo "data directory: ${data_directory}"
#  echo "schemas file: ${schemas_file}"
#  echo "aggregation file: ${aggregation_file}"

  [ -d ${data_directory} ]   || mkdir -p ${data_directory}
  [ -z ${schemas_file} ]     || cp /etc/go-carbon/go-carbon.schemas ${schemas_file}
  [ -z ${aggregation_file} ] || cp /etc/go-carbon/go-carbon.aggregation ${aggregation_file}
}


run() {

  go-carbon -config-print-default > ${DEFAULT_CONFIG}

  prepare

  go-carbon -check-config -config ${CONFIG_FILE}

  go-carbon -config ${CONFIG_FILE}
}

run

# EOF
