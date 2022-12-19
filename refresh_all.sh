#!/usr/bin/bash

DIRECTORY="/etc/pihole/pihole-bl-msft-telemetry-bsi"
REFRESH_CMD="git pull --no-rebase"
LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
REFRESH_SCRIPT="import_lists.sh"

touch $LOG_FILE

echo --------------------------------------- | tee -a $LOG_FILE | cat
echo Refreshing lists at $(date)             | tee -a $LOG_FILE | cat
echo --------------------------------------- | tee -a $LOG_FILE | cat
echo | tee -a $LOG_FILE | cat

cd $DIRECTORY
$REFRESH_CMD | tee -a $LOG_FILE | cat

$SHELL $REFRESH_SCRIPT | tee $LOG_FILE | cat

echo --------------------------------------- | tee -a $LOG_FILE | cat
echo Done refreshing lists at $(date)        | tee -a $LOG_FILE | cat
echo --------------------------------------- | tee -a $LOG_FILE | cat
echo | tee -a $LOG_FILE | cat
