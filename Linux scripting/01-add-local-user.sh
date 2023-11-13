#!/bin/bash

#author: jakcloudlearning
#github: https://github.com/jakcloudlearning

#Simple script to create user with some IF statements to check if everything is alright during the creation process.

if [[ ${UID} -ne 0 ]]
then
    echo 'Run this script under root privilages.'
    exit 1
fi

read -p 'Type username: ' USER_NAME
read -p 'Type your full name: ' FULL_NAME

useradd -c "${FULL_NAME}" -m ${USER_NAME}
if [[ ${?} -ne 0 ]]
then
   echo "You can not create user with the following username: ${USER_NAME}"
   exit 1
fi

SPECIAL_CHAR=$(echo '!@#$%^&*)(_+=-' | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c10)${SPECIAL_CHAR}
echo ${PASSWORD} | passwd --stdin ${USER_NAME}
if [[ ${?} -ne 0 ]]
then
   echo "Something went wrong..."
   exit 1
fi

passwd -e ${USER_NAME} 

echo "You created user with following credetials:
full name: ${FULL_NAME}
login: ${USER_NAME}
password: ${PASSWORD}
host: ${HOSTNAME}"

exit 0