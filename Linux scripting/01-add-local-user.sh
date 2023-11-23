#!/bin/bash

#author: jakcloudlearning
#github: https://github.com/jakcloudlearning

#13.11.23 Simple script to create user. I am using some IF statements to check if everything is alright during the creation process. There is also one example of password generation method.
#15.11.23 I upgraded this script. So now you can only pass arguments to the script and it will create user with auto-generated password. I also provided "--help" option which will display usage.
#19.11.23 All error messages are now displayed on standard error.Output from all other commands are suppresed.
#23.11.23 I added function "usage" to avoid duplication in script. There are now 2 options how to print USAGE of the script. First one is with single IF statement and another one is done by getopts 

usage(){
    echo "Script to create user
          Usage: ${0} USER_NAME [COMMENT]

          OPTIONS:
                   -h   --help   print usage of the script"
}

if [[ ${UID} -ne 0 ]]
then
    echo 'Run this script under root privilages.' >&2
    exit 1
fi

NUMBER_OF_PARAMETERS=${#}
if [[ ${NUMBER_OF_PARAMETERS} -lt 1 ]]
then
   echo "Error: You have to provide at lease 1 argument. Add --help to see more" >&2
   exit 1
fi

if [[ ${1} = '--help' ]]
then
   usage
   exit 1
fi

while getopts h TESTVAR
do
  case ${TESTVAR} in
    h)
      usage
      exit 0
      ;;
    ?)
      echo "Invadil option. See '--help' OR '-h'" >&2
      exit 1
      ;;
  esac
done

USER_NAME=$1
shift
COMMENT=$*
useradd -c "${COMMENT}" -m ${USER_NAME}

if [[ ${?} -ne 0 ]]
then
   echo "You can not create user with the following username: ${USER_NAME}" >&2
   exit 1
fi

SPECIAL_CHAR=$(echo '!@#$%^&*)(_+=-' | fold -w1 | shuf | head -c1)
PASSWORD=$(date +%s%N${RANDOM}${RANDOM} | sha256sum | head -c10)${SPECIAL_CHAR}
echo ${PASSWORD} | passwd --stdin ${USER_NAME} 1> /dev/null
if [[ ${?} -ne 0 ]]
then
   echo "Something went wrong..." >&2
   exit 1
fi

echo "You created user with following credetials:
full name: ${COMMENT}
login: ${USER_NAME}
password: ${PASSWORD}
host: ${HOSTNAME}"
echo
passwd -e ${USER_NAME} 1> /dev/null
exit 0
