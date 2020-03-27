#!/bin/bash
###############################################################################
# This file: https://tinyurl.com/tmkvlx3
# Full Archive: https://preview.tinyurl.com/rhtaopq
###############################################################################
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
###############################################################################
HOST_IP=${1}
LAST_OCTET=$(echo ${HOST_IP} | awk -F. '{print $4}')
###############################################################################
SSHHOME="${HOME}/.ssh"
CONFIGFILE="${SSHHOME}/config"
RSA="${SSHHOME}/id_rsa.fahclient${LAST_OCTET}"
RSAPUB="${RSA}.pub"
###############################################################################
FAHSRVUSER="root"
FAHSRVPASS="VMware1!"
FAHCONFIG="/etc/fahclient/config.xml"
FAHINIT="/etc/init.d/FAHClient"
FAHPORT="36330"
###############################################################################
CLIENTALIVE=$(timeout 1s bash -c "(echo >/dev/tcp/${HOST_IP}/${FAHPORT}) &>/dev/null && echo 1")
if [ -z "${CLIENTALIVE}" ]; then
  echo "ERROR: ${HOST_IP} appears to be offline on port ${FAHPORT}. Cannot continue"
  exit 1
fi;
###############################################################################
# Search for and install sshpass
INSTALLED=$(tdnf list installed | grep sshpass)
if [ -z "${INSTALLED}" ]l then
  tdnf -y install sshpass
fi;
###############################################################################
if [ ! -f ${RSAPUB} ]; then
    echo "Generating ${RSAPUB}"
    ssh-keygen -t RSA -C "folding@michaelpmcd.com" -f ${RSA} -N ''
fi;
###############################################################################
if [ ! -f ${CONFIGFILE} ]; then
  touch ${CONFIGFILE}
  chmod 600 ${CONFIGFILE}
fi;
###############################################################################
if [ -f ${CONFIGFILE} ]; then
  if [ -z "$(cat ${CONFIGFILE} | grep ${HOST_IP})" ]; then
    if [ -f ${RSAPUB} ]; then
      echo "Copying ID into place. You'll need to type in the password for this one."
      sshpass -p ${FAHSRVPASS} ssh-copy-id -i ${RSAPUB} -oStrictHostKeyChecking=no ${FAHSRVUSER}@${HOST_IP}
    fi;
    echo "Generating config file Host entry (${HOST_IP})"
    echo "" >> ${CONFIGFILE}
    echo "Host ${HOST_IP}" >> ${CONFIGFILE}
    echo "  PreferredAuthentications publickey" >> ${CONFIGFILE}
    echo "  IdentityFile ${RSA}" >> ${CONFIGFILE}
  fi;
fi;
###############################################################################
if [ -f ${FAHCONFIG} ]; then
  echo "Copying ${FAHCONFIG} into ${HOST_IP}"
  scp ${FAHCONFIG} ${FAHSRVUSER}@${HOST_IP}:${FAHCONFIG}
  ssh ${FAHSRVUSER}@${HOST_IP} "${FAHINIT} stop; sleep 2; ${FAHINIT} start;"
fi;
###############################################################################
