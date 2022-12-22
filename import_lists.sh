#!/usr/bin/bash

MY_VERSION='v0.2'
MY_YEAR='2022'
BANNER="$(basename $0) $MY_VERSION (c) $MY_YEAR Peter Schneider, provided under MIT License"

SUCCESS=0
ERROR=1

DB='/etc/pihole/gravity.db'
BACKUP_DB='/etc/pihole/gravity_pre_refresh_backup.db'

PIHOLE_CMD='/usr/local/bin/pihole'
FTL_CMD='/usr/bin/pihole-FTL'
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


# Functions
process_file () {

if [ -f $1 ]; then

    echo Nuking list $2...
    $PIHOLE_CMD $2 $NUKE_FLAGS

    cat $1 | grep -v '#' | grep -v -e '^$' | sort | uniq | while read LINE
    do
        $PIHOLE_CMD $2 $LINE

        # sleep to avoid DB locks due to commands in too fast succession
        sleep 0.5
        sync
    done

else
    echo File $1 not found!
fi

}

# Banner
echo $BANNER

# Mode of operation
MODE=${1^^}

if [ -z "$MODE" ]; then         # default mode
    MODE='ADD'
fi

if [ "$MODE" = "HELP" -o "$MODE" = "--HELP" -o "$MODE" = "-H" -o "$MODE" = "-?" -o "$MODE" = "/?" ]
then

    echo
    echo "Synopsis: import_lists.sh [MODE]"
    echo
    echo "This script will import the contents of the supplied file \"list_of_blocklists.txt\" into your"
    echo "Pi-Hole Gravity DB, where MODE may be one of:"
    echo
    echo "   - HELP:    display this help info"
    echo
    echo "   - ADD:     Only add new lists, don't do anything to existing lists.  This is the recommended mode"
    echo "              of operation when you have other sources for your block lists, too, other than my repo."
    echo "              It is also the default when no MODE is specified."
    echo
    echo "   - MERGE:   Add new lists, disable missing ones, re-enable disabled existing lists if they are in"
    echo "              the import file.  This retains group assignments on existing list entries. This is the recommended"
    echo "              mode of operation when my repo is the ONLY source of block lists for your Pi-Hole installation."
    echo
    echo "   - DELETE:  Add new lists, delete missing ones, re-enable disabled existing lists if they are in the"
    echo "              import file.  Group assignments on deleted groups are of course lost, and they cannot"
    echo "              just be re-enabled again, but will be newly imported when they happen to be in the"
    echo "              next version of the import file again."
    echo
    echo "   - FULL:    Fully replace all existing list entries in Gravity DB with the imported ones."
    echo "              Group assignments are thus lost.  That means that before inserting anything from the"
    echo "              import file, everything is deleted in the Gravity DB."
    echo

elif [ ! "$MODE" = "ADD" -a ! "$MODE" = "MERGE" -a ! "$MODE" = "DELETE" -a ! "$MODE" = "FULL" ]
then

    echo "ERROR: Unknown mode $MODE, please use the parameter \"HELP\" for information on script usage!"
    exit $ERROR

else
    echo "Mode of import operation is $MODE"
fi

# check that all we need to handle can be found
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

    echo Found blocklist file $BL_FILE!
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

        # sleep a bit to avoid DB lock issues...
        sleep 0.1

    done

    echo Done inserting blocklist entries - now verifying...
    echo
    echo --------------------------------------------------
    echo Imported lists:
    echo --------------------------------------------------
    echo

$SQL_EXEC_CMD <<EOF
SELECT address FROM tmp_adlist_import ORDER BY address;
.print
.print Number of imported lists:
.print --------------------------
.print
SELECT COUNT(*) FROM tmp_adlist_import;
.print
EOF

#
# Now we will update the Gravity DB table adlist from our imported file,
# depending on our specified import mode:
# - delete everything in FULL mode
# - delete missing lists in DELETE mode
# - mark lists that were not imported as disabled in MERGE mode
# - mark lists that were disabled but re-imported as enabled in DELETE and MERGE mode
# - insert new lists that were not present before in ALL modes
# - in ADD mode, we never delete or disable lists
# - in MERGE mode, we never delete lists
# - in DELETE mode, we only delete lists not in the import file
#

    echo
    echo Now processing imported lists with mode $MODE...
    echo

    if [ "$MODE" = "FULL" ]; then

        echo "Deleting tables gravity and adlist..."

$SQL_EXEC_CMD <<EOF
.changes on
.print gravity...
DELETE FROM gravity;
.print adlist...
DELETE FROM adlist;
EOF

    fi  # FULL


    if [ "$MODE" = "DELETE" ]; then

        echo "Deleting missing lists from tables gravity and adlist..."

$SQL_EXEC_CMD <<EOF
.changes on
.print gravity...
DELETE FROM gravity
 WHERE gravity.adlist_id IN
      (SELECT adlist.id
         FROM adlist
        WHERE adlist.address NOT IN
             (SELECT tmp_adlist_import.address
                FROM tmp_adlist_import
             )
      );
.print adlist...
DELETE FROM adlist
 WHERE NOT EXISTS
      (SELECT 1
         FROM tmp_adlist_import
        WHERE adlist.address = tmp_adlist_import.address);
EOF

    echo "Reenabling disabled lists that are in imported blocklist file..."

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

    fi  # DELETE


    if [ "$MODE" = "MERGE" ]; then

        echo "Disabling obsolete lists..."

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

    echo "Reenabling disabled lists that are in imported blocklist file..."

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

    fi  # MERGE


    # Common operations for all modes
    echo "Importing new list entries..."

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

    echo
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
