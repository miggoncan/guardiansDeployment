#!/bin/bash
####################################################################
#
# File: uninstall.sh
#
# Description: This script uninstalls the guardian's application.
#
#     It will DELETE the DATABASE, configuration files, logs...
#
# Usage: 
#     bash uninstall.sh
#
# Author: miggoncan
#
# Date: 2-july-2020
#
#####################################################################

echo "WARNING: You are about to delete all guardian' application data"
echo "INCLUDING THE DATABASE, configuration files, logs..."
read -p "Would you like to proceed? [y/N]: " answer

if [[ ${answer:=n} != "y" && $answer != "Y" ]]; then
    echo "The data has not been deleted"
    exit 1
fi

echo "Starting data deletion"

. config.sh

systemctl stop guardians
systemctl stop guardiansWebapp

rm -rf $LOG_DIR

rm -f $GUARDIANS_REST_KEY_FILE
rm -rf $GUARDIANS_REST_DIR_NAME
rm -rf $$GUARDIANS_REST_CONF_DIR
rm -rf $GUARDIANS_REST_KEYSTORE_DIR
rm -rf $GUARDIANS_REST_EXEC_DIR
rm -f /etc/systemd/system/$GUARDIANS_SERVICE_FILE

rm -rf $SCHEDULER_DIR_NAME
rm -rf $SCHEDULER_CONF_DIR
rm -rf $SCHEDULER_EXEC_DIR

rm -f $GUARDIANS_WEBAPP_KEY_FILE
rm -rf $GUARDIANS_WEBAPP_DIR_NAME
rm -rf $$GUARDIANS_WEBAPP_CONF_DIR
rm -rf $GUARDIANS_WEBAPP_KEYSTORE_DIR
rm -rf $GUARDIANS_WEBAPP_EXEC_DIR
rm -f /etc/systemd/system/$GUARDIANS_WEBAPP_SERVICE_FILE

userdel $GUARDIANS_REST_USER
userdel $GUARDIANS_WEBAPP_USER
groupdel $GUARDIANS_SHARED_GROUP

mysql << EOF
drop database $MYSQL_DB_NAME; 
drop user $MYSQL_USERNAME;
EOF

echo "Finished"