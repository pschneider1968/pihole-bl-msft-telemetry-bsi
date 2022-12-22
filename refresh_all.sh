#!/usr/bin/bash

# We assume the directory of this script is the cloned Git repo
MY_DIRECTORY=$(dirname $0)

LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
GIT_STATUS_CMD="git status"
GIT_PULL_CMD="git pull --no-rebase"
REFRESH_SCRIPT="import_lists.sh $1"

touch $LOG_FILE

echo -------------------------------------------------- | tee -a $LOG_FILE | cat
echo Refreshing lists at $(date)                        | tee -a $LOG_FILE | cat
echo -------------------------------------------------- | tee -a $LOG_FILE | cat

echo | tee -a $LOG_FILE | cat

cd $MY_DIRECTORY
$GIT_STATUS_CMD | tee -a $LOG_FILE | cat

echo Pulling from remote repo... | tee -a $LOG_FILE | cat
$GIT_PULL_CMD | tee -a $LOG_FILE | cat
$GIT_STATUS_CMD | tee -a $LOG_FILE | cat

echo

$SHELL $REFRESH_SCRIPT | tee -a $LOG_FILE | cat

echo ------------------------------------------------- | tee -a $LOG_FILE | cat
echo Done refreshing lists at $(date)                  | tee -a $LOG_FILE | cat
echo ------------------------------------------------- | tee -a $LOG_FILE | cat

echo | tee -a $LOG_FILE | cat
