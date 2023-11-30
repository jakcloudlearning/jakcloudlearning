#!/bin/bash

#author:    jakcloudlearning
#github:    https://github.com/jakcloudlearning
#contact:   jakub.cloud.learning@gmail.com

#30.11.23 This script will be used for cleaning up your temp files. I have an application which is creating a lot of temporary artifacts. Sadly, the artifacts are not automatically deleted by the application when they expire, so the performance of the whole machine goes down. This script will simply read the content of the directory, compare the timestamp and delete all created artifacts that are older than X minutes (10, 20,30 ... It's up to you). There is an option that you can create  backup of those artifacts. This script will be run with cron job.

usage(){
    echo "Script to create user
          Usage: ${0} /full/path/to/the/directory [OPTIONS]

          OPTIONS:
                   -h    print usage of the script
                   -b    create backup of files that will be removed"
}
 

if [[ ${#} -lt 1 ]]
then
  echo "ERROR: Please provide full path to the directory. See -h for more." >&2
fi

PATH=$1


while getopts hb TESTVAR
do
  case ${TESTVAR} in
   h)
     usage
     exit 0
     ;;
   b)
     backup
     ;;
   ?)
     echo "ERROR: Invalid option. See -h for more." >&2
     exit 1
     ;;
   esac
done





