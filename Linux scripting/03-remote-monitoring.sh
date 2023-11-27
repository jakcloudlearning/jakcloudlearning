#!/bin/bash

#26.11.23 I set up 3 VMs with vagrant admin1, server1, server2. I updated admin1's /etc/hosts (added mapping IP server), generated ssh-key and created file with names of servers. This script simply check connection with remote servers then it prints some basic information : hostname, status and uptime. I will add more functionality in near future.
#27.11.23 I added new functionality. Now its a monitoring script which may be run with cron job. Output of commands is pushed into file called monitoring.log. The output is colored based on the type of message.

SERVERS=$(cat /vagrant/servers)
if [[ -z ${SERVERS} ]]
then
  echo "Please put IPs of you servers to /vagrant/server. The file is empty." >$2
  exit 1 
fi

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

for IP in $SERVERS
do
  ping -c 1 ${IP} &>/dev/null
  if [[ "${?}" -ne 0 ]]
  then 
     echo -e "${RED}$(date +"%m-%d-%y") $(date +"%H:%M:%S") ERROR: Host ${IP} is unreachable. The host may be down or there is a firewall policy to block any icmp requests.${NC}" >> monitoring.log
  else
     echo -e "${GREEN}$(date +"%m-%d-%y") $(date +"%H:%M:%S") INFO: Host ${IP} is up. $(ssh     ${IP} hostname) $(ssh ${IP} uptime)${NC}" >> monitoring.log
  fi
done


