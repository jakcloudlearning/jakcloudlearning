#!/bin/bash

#author: jakcloudlearning
#github: https://github.com/jakcloudlearning

#13.11.23 Simple script to create user. I am using some IF statements to check if everything is alright during the creation process. There is also one example of password generation method.
#15.11.23 I upgraded this script. So now you can only pass arguments to the script and it will create user account with auto-generated password. I also provided "--help" option which will display usage.
#19.11.23 All error messages are now displayed on standard error.Output from all other commands are suppresed.
#23.11.23 I added function "usage" to avoid duplication in script. There are now 2 options how to print USAGE of the script. First one is with single IF statement and another one is done by getopts.
#23.11.23 I added new functionality. This script can create/delete/lock/unlock user account. I simply write one function for one operation. I use getopts loop with case statements. 

usage(){
    echo "Script to create user
          Usage: ${0} USER_NAME [COMMENT]

          OPTIONS:
                   -h   --help   print usage of the script"
 		   -c            create user ( sudo ${0} -c USER_NAME [COMMENT] ) 
                   -d            delete user ( sudo ${0} -d USER_NAME )
	           -l            lock user account ( sudo ${0} -d USER_NAME )
                   -u            unlock user account ( sudo ${0} -d USER_NAME )
}

create_user(){
  local USER_NAME=$1
  shift
  local COMMENT=$*
  useradd -c "${COMMENT}" -m ${USER_NAME}
  if [[ ${?} -ne 0 ]]
  then
     echo "Error: You can not create user with the following username: ${USER_NAME}" >&2
     exit 1
  fi
  local SPECIAL_CHAR=$(echo '!@#$%^&*)(_+=-' | fold -w1 | shuf | head -c1)
  local PASSWORD=$(date +%s%N${RANDOM} | sha256sum | head -c8)${SPECIAL_CHAR}
  echo ${PASSWORD} | passwd --stdin ${USER_NAME} 1> /dev/null

  if [[ ${?} -ne 0 ]]
  then
     echo "Something went wrong..." >&2
     exit 1
  fi

  echo "full name: ${COMMENT}
        login: ${USER_NAME}
        password: ${PASSWORD}
        host: ${HOSTNAME}"

  passwd -e ${USER_NAME} 1> /dev/null
}

delete_user(){
  local USER_NAME=${@}
  local UID_OF_USER=$(id -u ${USER_NAME} 2>/dev/null)
  if [[ ${UID_OF_USER} -eq NULL ]]
  then
     echo "Error occured. The user ${USER_NAME} do not exist." >&2
     exit 1
  fi
  
  if [[ ${UID_OF_USER} -lt 1000 ]]
  then
    echo "You can NOT delete user with UID 0 - 999!" >&2
    exit 1
  else
    echo "Do you want to delete home directory of ${USER_NAME} located at /home/${USER_NAME}? (y/n):"
    read YESNO
    case $YESNO in
      y) 
        userdel -r ${USER_NAME}
        echo "User ${USER_NAME} with UID ${UID_OF_USER} and home directory /home/${USER_NAME} has been deleted."
        ;;
      n)
        userdel ${USER_NAME}
        echo "User ${USER_NAME} with UID ${UID_OF_USER} has been deleted."
        ;;
      ?)
        echo "Error occured. Wrong option. Use only 'y' for yes or 'n' for no"
    esac  
  fi
  
}

lock_user(){
   local USER_NAME=${@}
   local UID_OF_USER=$(id -u ${USER_NAME} 2>/dev/null)
   if [[ ${UID_OF_USER} -eq NULL ]]
   then
      echo "Error occured. The user ${USER_NAME} do not exist." >&2
      exit 1
   else
      chage -E -0 ${USER_NAME}
      echo "User account ${USER_NAME} has been locked."
   fi
}

unlock_user(){
   local USER_NAME=${@}
   local UID_OF_USER=$(id -u ${USER_NAME} 2>/dev/null)
   if [[ ${UID_OF_USER} -eq NULL ]]
   then
      echo "Error occured. The user ${USER_NAME} do not exist." >&2
      exit 1
   else
      chage -E -1 ${USER_NAME}
      echo "User account ${USER_NAME} has been unlocked."
   fi
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

while getopts c:d:l:u:h TESTVAR
do
  case ${TESTVAR} in
    h)
      usage
      exit 0
      ;;
    d)
      delete_user $2
      ;;
    c)
      shift 
      create_user $1 $*
      ;;
    l)
      lock_user $2
      ;;
    u)
      unlock_user $2
      ;;
    ?)
      echo "Invadil option. See '--help' OR '-h'" >&2
      exit 1
      ;;
  esac
done

exit 0
