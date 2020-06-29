. config.sh

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

userdel $GUARDIANS_REST_USER

mysql << EOF
drop database $MYSQL_DB_NAME; 
drop user $MYSQL_USERNAME;
EOF