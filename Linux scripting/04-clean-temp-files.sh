#!/bin/bash

#author:    jakcloudlearning
#github:    https://github.com/jakcloudlearning
#contact:   jakub.cloud.learning@gmail.com

#30.11.23 This script will be used for cleaning up your temp files. I have an application which is creating a lot of temporary artifacts. Sadly, the artifacts are not automatically deleted by the application when they expire, so the performance of the whole machine goes down. This script will simply read the content of the directory, compare the timestamp and delete all created artifacts that are older than X minutes (10, 20,30 ... It's up to you). There is an option that you can create  backup of those artifacts. This script will be run with cron job.
#7.12.23 The script is done. I changed logic a little bit. Now the path to the temp_folder has to be changed in the script. If you provide option -b it will mv all files that meet the condition to the backup folder, then those files will be compressed to tar.gz extention. If you do not provide option -b it will simply remove all files in temp_folder which meet the condition.

usage(){
    echo "Script to create user
          Usage: ${0} [OPTIONS]

          OPTIONS:
                   -h    print usage of the script
                   -b    create backup of files that will be removed"
}

backup(){
  MOVE=$(echo ${FILE} | awk -F '/' '{print $4}')
  echo ${MOVE}
  DAT=$(date)
  DAT=$(echo ${DAT} | awk -F ' ' '{print $1 $2 $3 $4}')
  DAT="${DAT// /-}"
  DAT="${DAT//:/-}"
  mkdir /vagrant/project1/backups/${DAT}
  for FILE in $FILES
  do
    if [[ -f ${FILE} ]]
    then
        mv $FILE /vagrant/project1/backups/${DAT}/${MOVE} &>/dev/null
        
    fi
  done
  
  tar czfv /vagrant/project1/backups/${DAT}.tar.gz /vagrant/project1/backups/${DAT} &>/dev/null
  rm -rf /vagrant/project1/backups/${DAT}
}
PAT=/vagrant/project1/temp_folder/
find ${PAT} -mmin +40 > help_file.txt
FILES=$(cat help_file.txt)



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

for FILE in $FILES
do
  if [[ -f ${FILE} ]]
  then
     rm -rf ${FILE}
  fi
done

rm -rf help_file.txt

exit 0




