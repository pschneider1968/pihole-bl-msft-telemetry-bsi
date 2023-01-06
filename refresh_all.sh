#!/usr/bin/bash

# We assume the directory of this script is the cloned Git repo
MY_DIRECTORY=$(dirname $0)

LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
GIT_STATUS_CMD="git status"
GIT_PULL_CMD="git pull --no-rebase"
REFRESH_SCRIPT="import_lists.sh $1"
SHELL=/bin/bash

if [[ ! ":$PATH:" == *":/usr/local/bin:"* ]]; then
    PATH=/usr/local/bin:$PATH
fi

touch $LOG_FILE

echo "--------------------------------------------------" 2>&1 | tee -a $LOG_FILE | cat
echo "Refreshing lists at $(date)                       " 2>&1 | tee -a $LOG_FILE | cat
echo "--------------------------------------------------" 2>&1 | tee -a $LOG_FILE | cat
echo "" 2>&1 | tee -a $LOG_FILE | cat
echo "PATH=$PATH" 2>&1 | tee -a $LOG_FILE | cat
echo "" 2>&1 | tee -a $LOG_FILE | cat

cd $MY_DIRECTORY
$GIT_STATUS_CMD 2>&1 | tee -a $LOG_FILE | cat

echo "Pulling from remote repo..." 2>&1 | tee -a $LOG_FILE | cat
$GIT_PULL_CMD 2>&1 | tee -a $LOG_FILE | cat
$GIT_STATUS_CMD 2>&1 | tee -a $LOG_FILE | cat

echo "" 2>&1 | tee -a $LOG_FILE | cat

$SHELL $REFRESH_SCRIPT 2>&1 | tee -a $LOG_FILE | cat

echo "" 2>&1 | tee -a $LOG_FILE | cat
echo "-------------------------------------------------" 2>&1 | tee -a $LOG_FILE | cat
echo "Done refreshing lists at $(date)                 " 2>&1 | tee -a $LOG_FILE | cat
echo "-------------------------------------------------" 2>&1 | tee -a $LOG_FILE | cat
echo "" 2>&1 | tee -a $LOG_FILE | cat

