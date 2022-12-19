#!/usr/bin/bash

SUCCESS=0
ERROR=1

PIHOLE_CMD=$(which pihole)

WE_FILE=whitelist_exact.txt
WE_FLAGS='-w -nr'

WR_FILE=whitelist_regex.txt
WR_FLAGS='--white-regex -nr'

BE_FILE=blacklist_exact.txt
BE_FLAGS='-b -nr'

BR_FILE=blacklist_regex.txt
BR_FLAGS='--regex -nr'

NUKE_FLAGS='--nuke'

UPDATE_DB_FLAGS='-g'
RELOAD_FLAGS='restartdns reloadlists'

process_file () {

if [ -f $1 ]; then

    echo Nuking list $2...
    $PIHOLE_CMD $2 $NUKE_FLAGS

    cat $1 | grep -v '#' | grep -v -e '^$' | sort | while read LINE
    do
        $PIHOLE_CMD $2 $LINE
    done

else
    echo File $1 not found!
fi

}


if [ ! -z $PIHOLE_CMD ]; then
    if [ -x $PIHOLE_CMD ]; then
        echo Found executable Pi-Hole command $PIHOLE_CMD!
    else
        echo Pi-Hole command $PIHOME_CMD not found, aborting!
        exit $ERROR
    fi
else
    echo Pi-Hole command $PIHOME_CMD not found, aborting!
    exit $ERROR
fi

echo
echo Processing $WE_FILE...
process_file $WE_FILE $WE_FLAGS

echo
echo Processing $WR_FILE...
process_file $WR_FILE $WR_FLAGS

echo
echo Processing $BE_FILE...
process_file $BE_FILE $BE_FLAGS

echo
echo Processing $BR_FILE...
process_file $BR_FILE $BR_FLAGS

echo
echo Now updating all adlists and Gravity DB...
$PIHOLE_CMD $UPDATE_DB_FLAGS

echo
echo Restarting DNS service...
$PIHOLE_CMD $RELOAD_FLAGS

echo Done!

exit $SUCCESS
