#!/usr/bin/bash

DIRECTORY="/etc/pihole/pihole-bl-msft-telemetry-bsi"
GIT_STATUS_CMD="git status"
REFRESH_CMD="git pull --no-rebase"
LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
REFRESH_SCRIPT="import_lists.sh"

touch $LOG_FILE

echo -------------------------------------------------- | tee -a $LOG_FILE | cat
echo Refreshing lists at $(date)                        | tee -a $LOG_FILE | cat
echo -------------------------------------------------- | tee -a $LOG_FILE | cat

echo | tee -a $LOG_FILE | cat

cd $DIRECTORY
$GIT_STATUS_CMD | tee -a $LOG_FILE | cat

echo Pulling from remote repo... | tee -a $LOG_FILE | cat
$REFRESH_CMD | tee -a $LOG_FILE | cat
$GIT_STATUS_CMD | tee -a $LOG_FILE | cat

$SHELL $REFRESH_SCRIPT | tee -a $LOG_FILE | cat

echo ------------------------------------------------- | tee -a $LOG_FILE | cat
echo Done refreshing lists at $(date)                  | tee -a $LOG_FILE | cat
echo ------------------------------------------------- | tee -a $LOG_FILE | cat

echo | tee -a $LOG_FILE | cat
