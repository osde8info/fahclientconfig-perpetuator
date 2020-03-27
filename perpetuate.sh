#!/bin/bash

# https://tinyurl.com/tmkvlx3

if [ -z "${HOME}" ]; then
  echo "ERROR: Relies on environment variables. Can't run in CRON"
  exit 1;
fi;
if [ -z "${1}" ]; then
  echo "ERROR: Need to know IP to perpetuate to!"
  echo "    Example: ${0} 192.168.19.50"
  echo "       Sets up 192.168.19.50 with SSH keys"
  exit 1;
fi;
HOST_IP=${1}
LAST_OCTET=$(${HOST_IP} | awk -F. '{print $4}')
FAHSRVUSER="root"
SSHHOME="${HOME}/.ssh"
CONFIGFILE="${SSHHOME}/config"
RSA="${SSHHOME}/id_rsa.fahclient${LAST_OCTET}"
RSAPUB="${RSA}.pub"
FAHCONFIG="/etc/fahclient/config.xml"
FAHINIT="/etc/init.d/FAHClient"
if [ ! -f ${RSAPUB} ]; then
    echo "Generating ${RSAPUB}"
    ssh-keygen -t RSA -C "folding@michaelpmcd.com" -f ${RSA} -N ''
fi;
if [ ! -f ${CONFIGFILE} ]; then
  touch ${CONFIGFILE}
  chmod 600 ${CONFIGFILE}
fi;
if [ -f ${CONFIGFILE} ]; then
  if [ -z "$(cat ${CONFIGFILE} | grep ${HOST_IP})" ]; then
    echo "Host ${HOST_IP}" >> ${CONFIGFILE}
    echo "  Preferredauthentications publickey" >> ${CONFIGFILE}
    echo "  IdentityFile ${RSA}" >> ${CONFIGFILE}
    echo "" >> ${CONFIGFILE}
    if [ -f ${RSAPUB} ]; then
      echo "Copying ID into place. You'll need to type in the password for this one."
      ssh-copy-id -i ${RSAPUB} -oStrictHostKeyChecking=no ${FAHSRVUSER}@${HOST_IP}
    fi;
  fi;
fi;
if [ -f ${FAHCONFIG} ]; then
  scp ${FAHCONFIG} ${FAHSRVUSER}@${HOST_IP}:${FAHCONFIG}
  ssh ${FAHSRVUSER}@${HOST_IP} "${FAHINIT} stop; sleep 2; ${FAHINIT} start;"
fi;
