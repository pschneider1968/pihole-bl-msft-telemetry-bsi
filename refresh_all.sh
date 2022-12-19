#!/usr/bin/bash

DIRECTORY="/etc/pihole/pihole-bl-msft-telemetry-bsi"
REFRESH_CMD="git pull --no-rebase"
LOG_FILE="/var/log/pihole/refresh_pihole_lists.log"
REFRESH_SCRIPT="import_lists.sh"

cd $DIRECTORY
$REFRESH_CMD

touch $LOG_FILE
$SHELL $REFRESH_SCRIPT | tee $LOG_FILE | cat
