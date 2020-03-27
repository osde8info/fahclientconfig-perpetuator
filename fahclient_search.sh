#!/bin/bash

if [ -z "${1}" ]; then
  echo "ERROR: Need to know 3rd Octet, Start, and Finish"
  echo "    Example: ${0} 19 1 250"
  echo "       Loops from 192.168.19.1-250"
  exit 1;
fi;
if [ -z "${2}" ]; then
  echo "ERROR: Need to know 3rd Octet, Start, and Finish"
  echo "    Example: ${0} ${1} 1 250"
  echo "       Loops from 192.168.19.1-250"
  exit 1;
fi;
if [ -z "${3}" ]; then
  echo "ERROR: Need to know 3rd Octet, Start, and Finish"
  echo "    Example: ${0} ${1} ${2} 250"
  echo "       Loops from 192.168.19.1-250"
  exit 1;
fi;
if [ -z "${HOME}" ]; then
  echo "ERROR: Relies on environment variables. Can't run in CRON"
  exit 1;
fi;
IPBASE="192.168"
HOSTSFILE="${HOME}/fahhosts"
FAHPORT="36330"
START_IP=${2}
END_IP=${3}
if [ ${2} -gt ${3} ]; then
  echo "WARNING: Flipping arguments: ${2} and ${3}"
  START_IP=${3}
  END_IP=${2}
fi;
if [ ! -f ${HOSTSFILE} ]; then
  touch ${HOSTSFILE}
fi;
for i in $(seq ${START_IP} ${END_IP}); do
  HOST_IP="${IPBASE}.${1}.${i}"
  echo "Checking ${HOST_IP}"
  CLIENTALIVE=$(timeout 1s bash -c "(echo >/dev/tcp/${HOST_IP}/${FAHPORT}) &>/dev/null && echo 1")
  if [ ${CLIENTALIVE} ]; then
    echo ${HOST_IP} >> ${HOSTSFILE}
  fi;
done;
