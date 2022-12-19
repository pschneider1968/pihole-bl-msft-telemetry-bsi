#!/usr/bin/bash

DIRECTORY="/etc/pihole/pihole-bl-msft-telemetry-bsi"
REFRESH_CMD="git pull --no-rebase"
LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
REFRESH_SCRIPT="import_lists.sh"

touch $LOG_FILE

cd $DIRECTORY
$REFRESH_CMD >> $LOG_FILE

echo --------------------------------------- >> $LOG_FILE
echo Refreshing lists at $(date) >> $LOG_FILE
echo ---------------------------------------  >> $LOG_FILE
echo  >> $LOG_FILE

$SHELL $REFRESH_SCRIPT | tee $LOG_FILE | cat
