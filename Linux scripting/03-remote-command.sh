#!/bin/bash

#26.11.23 I set up 3 VMs with vagrant admin1, server1, server2. I updated admin1's /etc/hosts (added mapping IP server), generated ssh-key and created file with names of servers. This script simply check connection with remote servers then it prints some basic information : hostname, status and uptime. I will add more functionality in near future.

SERVERS=$(cat /vagrant/servers)
if [[ -z ${SERVERS} ]]
then
  echo "Please put IPs of you servers to /vagrant/server. The file is empty." >$2
  exit 1 
fi

for SERVER in $SERVERS
do
  echo "Pinging ${SERVER}..." 
  ping -c 1 ${SERVER} &>/dev/null
  if [[ "${?}" -ne 0 ]]
  then 
     echo "${SERVER} is unreachable. The ${SERVER} may be down or there is a firewall policy to block any icmp requests."
  else
     echo "${SERVER} is UP.
           HOSTNAME:$(ssh ${SERVER} hostname)
           UPTIME:$(ssh ${SERVER} uptime)
           
           "
  fi
done


