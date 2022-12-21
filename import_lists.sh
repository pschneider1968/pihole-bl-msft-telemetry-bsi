#!/usr/bin/bash

SUCCESS=0
ERROR=1

DB=/etc/pihole/gravity.db
BACKUP_DB=/etc/pihole/gravity_pre_refresh_backup.db

PIHOLE_CMD="/usr/local/bin/pihole"
FTL_CMD="/usr/bin/pihole-FTL"
SQL_EXEC_CMD="$FTL_CMD sqlite3 $DB"

BL_FILE=list_of_blocklists.txt

WE_FILE=whitelist_exact.txt
WE_FLAGS='whitelist --noreload --quiet'

WR_FILE=whitelist_regex.txt
WR_FLAGS='--white-regex --noreload --quiet'

BE_FILE=blacklist_exact.txt
BE_FLAGS='blacklist --noreload --quiet'

BR_FILE=blacklist_regex.txt
BR_FLAGS='--regex --noreload --quiet'

NUKE_FLAGS='--nuke'

UPDATE_DB_FLAGS='-g'
RELOAD_FLAGS='restartdns reload-lists'

process_file () {

if [ -f $1 ]; then

    echo Nuking list $2...
    $PIHOLE_CMD $2 $NUKE_FLAGS

    cat $1 | grep -v '#' | grep -v -e '^$' | sort | uniq | while read LINE
    do
        $PIHOLE_CMD $2 $LINE

        # sleep to avoid DB locks due to commands in too fast succession
        sleep 0.1
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

if [ ! -z $FTL_CMD ]; then
    if [ -x $FTL_CMD ]; then
        echo Found executable pihole-FTL command $FTL_CMD!
    else
        echo pihole-FTL command $FTL_CMD not found, aborting!
        exit $ERROR
    fi
else
    echo pihole-FTL command $FTL_CMD not found, aborting!
    exit $ERROR
fi

if [ -f $DB ]; then
    echo Found Gravity DB $DB!
else
    echo Gravity DB $DB not found, aborting!
    exit $ERROR
fi


# Check that we have a blocklist file at all, otherwise we dont want to make noise...

if [ -f $BL_FILE -a -r $BL_FILE ]; then

    echo Blocklist file $BL_FILE found!
    echo Using "$SQL_EXEC_CMD" to access Gravity DB...

    # Before doing anything serious, we make a full DB backup
    echo Backing up DB $DB to $BACKUP_DB...

$SQL_EXEC_CMD <<EOF
.backup main $BACKUP_DB
EOF

    echo Importing...
    
$SQL_EXEC_CMD <<EOF
DROP TABLE IF EXISTS tmp_adlist_import;
CREATE TABLE tmp_adlist_import (address TEXT NOT NULL UNIQUE);
.schema tmp_adlist_import
EOF

    cat $BL_FILE | grep -v '#' | grep -v -e '^$' | sort | uniq | while read LINE
    do

$SQL_EXEC_CMD <<EOF
INSERT INTO tmp_adlist_import (address) VALUES ('$LINE');
EOF

    done

    echo Done inserting blocklist entries - now verifying...

$SQL_EXEC_CMD <<EOF
SELECT address FROM tmp_adlist_import ORDER BY address;
SELECT COUNT(*) FROM tmp_adlist_import;
EOF

#
# Now we will update the Gravity DB table adlist from our imported file, as follows:
# - mark lists that were not imported as disabled
# - mark lists that were disabled but re-imported as enabled
# - insert new lists that were not present before
# So because we do not delete any records from adlist, no group assignments will be lost!
#

    echo
    echo Now processing imported lists...
    echo
    echo "1) Disabling obsolete lists..."

$SQL_EXEC_CMD <<EOF
.changes on
UPDATE adlist
   SET enabled = FALSE
 WHERE enabled = TRUE
   AND NOT EXISTS
      (SELECT 1
         FROM tmp_adlist_import
        WHERE adlist.address = tmp_adlist_import.address);
EOF

    echo "2) Reenabling disabled lists that are in imported blocklist file..."

$SQL_EXEC_CMD <<EOF
.changes on
UPDATE adlist
   SET enabled = TRUE
 WHERE enabled = FALSE
   AND EXISTS
      (SELECT 1
         FROM tmp_adlist_import
        WHERE adlist.address = tmp_adlist_import.address);
EOF

    echo "3) Importing new list entries..."

$SQL_EXEC_CMD <<EOF
.changes on
INSERT INTO adlist (address, enabled)
SELECT tmp_adlist_import.address, TRUE
  FROM tmp_adlist_import
 WHERE NOT EXISTS
      (SELECT 1
         FROM adlist
        WHERE adlist.address = tmp_adlist_import.address);
EOF

    # For the time being, we do not drop our temporary import table now, so that
    # it is possible to review its contents and eventually debug issues from the import

    echo Done with processing the imported lists!


else
    echo No blocklist file $BL_FILE found, will not update adlist table in Gravity DB!
fi


echo Restarting DNS service to get rid of DB locks before updating lists...
$PIHOLE_CMD $RELOAD_FLAGS

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
