#!/bin/bash

# wait for
#
wait_for_port() {

  port=${1}

  echo -n "wait for port ${port} .."

  # now wait for ssh port
  RETRY=40
  until [[ ${RETRY} -le 0 ]]
  do
    timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${port}" 2> /dev/null
    if [ $? -eq 0 ]
    then
      echo "  okay"
      break
    else
      echo "."
      sleep 3s
      RETRY=$(expr ${RETRY} - 1)
    fi
  done

  if [[ $RETRY -le 0 ]]
  then
    echo "could not connect to the graphite instance"
    exit 1
  fi
}

inspect() {

  echo "inspect needed containers"
  for d in $(docker ps | tail -n +2 | awk  '{print($1)}')
  do
    docker inspect --format '{{with .State}} {{$.Name}} has pid {{.Pid}} {{end}}' ${d}
  done
}


# echo "wait 10 seconds for start"
# sleep 10s

if [[ $(docker ps | tail -n +2 | wc -l) -eq 1 ]]
then
  inspect
  wait_for_port 2003
  wait_for_port 2004
  wait_for_port 7002
  wait_for_port 7003
  wait_for_port 7007
  wait_for_port 8080

  exit 0
else
  echo "please run "
  echo " make start"
  echo "before"

  exit 1
fi
