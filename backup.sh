#!/bin/bash
#
# rsync command to backup home drive recursively to /mnt/nvme1n1p1
# while copying deleted files to /mnt/nvme1n1p1/oldbackups
# each oldbackups entry is in a timestamped directory
#
# For daily execution create a symlink to the script in cron.daily:
# sudo ln -s /home/rob/Files/Scripts/backup.sh backup
#
# created by rob wijhenke november 2020
# v1.0 rev-d
#

# set some variables
OLDBACKUPS="/mnt/nvme1n1p1/oldbackups"
BACKUPS="/mnt/nvme1n1p1/backup"
SCRIPTS="/home/rob/Files/Scripts"

# sync it
sudo rsync -a -v --progress --backup-dir=$OLDBACKUPS/`date +%Y-%m-%d_%H.%M` --delete -b -s --include-from $SCRIPTS/backupinclude.txt --exclude-from $SCRIPTS/backupexclude.txt /home/rob $BACKUPS 2>$SCRIPTS/backup-errors.log


# open log in case of errors
if [ -s $SCRIPTS/backup-errors.log ]
then
    kate $SCRIPTS/backup-errors.log
else
    # delete backup dirs older then n days (where n = n+1 so 5 = 6 days counting from 0)
    find $OLDBACKUPS/* -maxdepth 0 -type d -mtime +5 | xargs sudo rm -rf;2>$SCRIPTS/rm-errors.log
    if [ -s $SCRIPTS/rm-errors.log ]
    then
        kate $SCRIPTS/rm-errors.log
    fi
    notify-send "Backup finished"
fi
