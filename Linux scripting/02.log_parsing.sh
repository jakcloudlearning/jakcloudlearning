#!/bin/bash

#author: jakcloudlearning
#github: https://github.com/jakcloudlearning
#contact: jakub.cloud.learning@gmail.com:

#25.11.23 Script for log parsing. Script displays the number of failed login attempts by IP address and location. 
          #I used syslog_sample from the github (https://github.com/logpai/loghub).
LOG_FILE=$1
if [[ ! -e "${LOG_FILE}" ]]
then
   echo "Cannot open ${LOG_FILE}" >&2
   exit 1
fi

cat ${LOG_FILE} | grep Failed | grep -v root | awk -F 'from ' '{print $2}' | awk -F ' ' '{print $1}' | uniq -c | sort -n > helper

NUMBER_OF_LINES=$(cat helper | wc -l)
NUM=1
rm -rf attackers_info
while [[ ${NUMBER_OF_LINES} -ge ${NUM} ]]
do
  COUNT=$(sed -n ${NUM}p  helper | awk -F ' ' '{print $1}')
  if [[ ${COUNT} -ge 8  ]]
  then
     COUNTRY=$(geoiplookup $(sed -n "${NUM}p" helper | awk -F ' ' '{print $2}') | awk -F ', ' '{print $2}')
     if [[ -z "${COUNTRY}" ]]
     then
        COUNTRY="Not found"
     fi
     IP_COUNT=$(sed -n "${NUM}p" helper)	
     echo "${IP_COUNT},${COUNTRY}" >> attackers_info
  fi
  ((NUM++))
done

rm -rf helper
exit 0

