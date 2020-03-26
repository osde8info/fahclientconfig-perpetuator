#!/bin/bash

# https://tinyurl.com/tmkvlx3

if [ -z "${HOME}" ]; then
  echo "ERROR: Relies on environment variables. Can't run in CRON"
  exit 1;
fi;
if [ -z "${1}" ]; then
  echo "ERROR: Need to know both octets!"
  echo "    Example: ${0} 19 50"
  exit 1;
fi;
if [ -z "${2}" ]; then
  echo "ERROR: Need to know both octets!"
  echo "    Example: ${0} 19 50"
  exit 1;
fi;
IPBASE="192.168"
IP="${IPBASE}.$1.$2"
FAHSRVUSER="root"
SSHHOME="${HOME}/.ssh"
CONFIGFILE="${SSHHOME}/config"
RSA="${SSHHOME}/id_rsa.fahclient${2}"
RSAPUB="${RSA}.pub"
FAHCONFIG="/etc/fahclient/config.xml"
FAHINIT="/etc/init.d/FAHClient"
if [ ! -f ${RSAPUB} ]; then
    echo "Generating ${RSAPUB}"
    ssh-keygen -t RSA -C "folding@michaelpmcd.com" -f ${RSA} -N ''
fi;
if [ ! -f ${RSAPUB} ]; then
  echo "Copying ID into place. You'll need to type in the password for this one."
  ssh-copy-id -i ${RSAPUB} -oStrictHostKeyChecking=no ${FAHSRVUSER}@${IP}
fi;
if [ ! -f ${CONFIGFILE} ]; then
  touch ${CONFIGFILE}
  chmod 600 ${CONFIGFILE}
fi;
if [ -f ${CONFIGFILE} ]; then
  if [ -z "$(cat ${CONFIGFILE} | grep ${IP})" ]; then
    echo "Host ${IP}" >> ${CONFIGFILE}
    echo "  Preferredauthentications publickey" >> ${CONFIGFILE}
    echo "  IdentityFile ${RSA}" >> ${CONFIGFILE}
    echo ""
  fi;
fi;
if [ -f ${FAHCONFIG} ]; then
  scp ${FAHCONFIG} ${FAHSRVUSER}@${IP}:${FAHCONFIG}
  ssh ${FAHSRVUSER}@${IP} "${FAHINIT} stop; sleep 2; ${FAHINIT} start;"
fi;
