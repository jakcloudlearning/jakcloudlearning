#!/bin/bash

#author: jakcloudlearning
#github: https://github.com/jakcloudlearning

#13.11.23 Simple script to create user. I am using some IF statements to check if everything is alright during the creation process. There is also one example of password generation method.
#15.11.23 I upgraded this script. So now you can only pass arguments to the script and it will create user with auto-generated password. I also provided "--help" option which will display usage.
if [[ ${UID} -ne 0 ]]
then
    echo 'Run this script under root privilages.'
    exit 1
fi

NUMBER_OF_PARAMETERS=${#}
if [[ ${NUMBER_OF_PARAMETERS} -lt 1 ]]
then
   echo "Error: You have to provide at lease 1 argument."
   echo "Add --help to see more"
   exit 1
fi

if [[ ${1} = '--help' ]]
then
   echo
   echo "Script for create user with auto-generated password."
   echo "Usage:"    
   echo "./01-add-local-user.sh <USER_NAME> <COMMENT>"
   echo "Argument <COMMENT> is not required."
   echo
   exit 1
fi

USER_NAME=$1
shift
COMMENT=$*
useradd -c "${COMMENT}" -m ${USER_NAME}

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
