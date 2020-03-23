#!/bin/bash

FINAL_OCTETSET="$1.$2"
ssh-copy-id -i ~/.ssh/id_rsa.pub -oStrictHostKeyChecking=no root@192.168.${FINAL_OCTETSET}
scp /etc/fahclient/config.xml root@192.168.${FINAL_OCTETSET}:/etc/fahclient/config.xml
ssh root@192.168.${FINAL_OCTETSET} '/etc/init.d/FAHClient stop; sleep 2; /etc/init.d/FAHClient start;'
