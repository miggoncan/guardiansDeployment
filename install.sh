#!/bin/bash
####################################################################
#
# File: install.sh
#
# Description: This script installs the guardians rest and the guardians 
#     webapp as two standalone services.
#
#     The installed services can be started/stopped with the common 
#     systemctl command.
#     E.g. 'systemctl start guardians' or 'systemctl stop guardiansWebapp'
#
#     For this script to function properly, the commands $MYSQL, $GIT
#     and $PYTHON have to be on the PATH.
#
# Usage: 
#     bash install.sh
#
# Author: miggoncan
#
# Date: 28-june-2020
#
#####################################################################

CURR_DIR="$(pwd)"
# Set the current directory to be this script's directory
cd "$(dirname "$0")"

# Load the configuration
. config.sh

# A summury on how to use this script
USAGE="bash $0"
# Name of mysql local client. It has to be in PATH
MYSQL="mysql"
# Name of the git command. It has to be in PATH
GIT="git"
# The python command. It has to be in PATH
PYTHON="python3"

# Command used to generate passwords
GEN_PASSWORD_COMMAND="$PYTHON generatePassword.py $PASSWORD_LENGTH"


# This function checks whether the name given as first arguments exists
# in PATH
#
# Example usage:
#     is_bin_in_path ls && echo "in path" || echo "not in path"
#
# This code is from <https://stackoverflow.com/a/53798785/13688761>
function is_bin_in_path {
  builtin type -P "$1" &> /dev/null
}

# This functions prints an error message and exits with error code 1
# It takes one argument, which is the program not installed
# Example usage:
#     notInsalled ls
notInstalled() {
    echo "$1 is not installed or it is not in PATH"
    echo "Please, install it or make it visible in PATH"
    exit 1
}

# This function takes one argument which is the error message to be shown
showUnexpectedError() {
    echo "==========================================="
    echo "ERROR:"
    echo "$1"
    echo "==========================================="
    cleanUp
    exit 1
}

# Remove temporary files created during the installation
cleanUp()  {
    echo "Cleaning up"

    rm -rf $GUARDIANS_REST_DIR_NAME
    rm -f $GUARDIANS_REST_KEY_FILE

    rm -rf $SCHEDULER_DIR_NAME

    rm -rf $GUARDIANS_WEBAPP_DIR_NAME
    rm -f $GUARDIANS_WEBAPP_KEY_FILE
}


main () {
    # Exit if the user does not have sudo privileges
    if [[ $(id -u) -ne 0 ]]; then
        echo "This script needs to be run with root privileges"
        echo "Try using 'sudo $USAGE' or 'su -c \"$USAGE\"'"
        exit 1
    fi


    echo "Checking dependencies"
    # Check the needed commands exist. If any does not exist, the 
    # program will exit with error code 1
    is_bin_in_path $MYSQL || notInstalled $MYSQL
    is_bin_in_path $GIT || notInstalled $GIT
    is_bin_in_path $PYTHON || notInstalled $PYTHON


    # Request user and password used to authenticate to the webapp
    echo
    echo "Please, input usernames and password used to authenticate to the webapp"
    PASSWORDS_MATCH=0
    while [ $PASSWORDS_MATCH -eq 0 ]; do
        read -p "Username: " webappUsername
        read -s -p "Password: " webappPassword
        echo
        read -s -p "Repeat password: " webappPasswordRepeated
        echo

        if [ $webappPassword != $webappPasswordRepeated ]; then
            echo "The passwords do not match. Please, repeat them"
        else
            PASSWORDS_MATCH=1
        fi
    done
    echo


    echo "Creating group: '$GUARDIANS_SHARED_GROUP' and users: '$GUARDIANS_REST_USER', '$GUARDIANS_WEBAPP_USER'"
    groupadd $GUARDIANS_SHARED_GROUP
    useradd --no-create-home $GUARDIANS_REST_USER --groups $GUARDIANS_SHARED_GROUP
    usermod --lock $GUARDIANS_REST_USER
    useradd --no-create-home $GUARDIANS_WEBAPP_USER --groups $GUARDIANS_SHARED_GROUP
    usermod --lock $GUARDIANS_WEBAPP_USER


    echo "Creating needed directories"

    mkdir -p $LOG_DIR
    mkdir -p $LOG_DIR_WEBAPP

    mkdir -p $GUARDIANS_REST_CONF_DIR
    mkdir -p $GUARDIANS_REST_KEYSTORE_DIR
    mkdir -p $GUARDIANS_REST_EXEC_DIR

    mkdir -p $SCHEDULER_CONF_DIR
    mkdir -p $SCHEDULER_EXEC_DIR

    mkdir -p $GUARDIANS_WEBAPP_CONF_DIR
    mkdir -p $GUARDIANS_WEBAPP_KEYSTORE_DIR
    mkdir -p $GUARDIANS_WEBAPP_EXEC_DIR


    echo "Generating passwords"
    passwordMysql="$($GEN_PASSWORD_COMMAND)"
    passwordKeystoreRest="$($GEN_PASSWORD_COMMAND)"
    passwordKeystoreWebapp="$($GEN_PASSWORD_COMMAND)"
    passwordBasicAuth="$($GEN_PASSWORD_COMMAND)"


    echo "Generating the keys for guardians rest service and the webapp"

    bash generatePkcs12Key.sh "$passwordKeystoreRest" \
        "--alias=$GUARDIANS_REST_KEY_ALIAS" \
        "--file=$GUARDIANS_REST_KEY_FILE"
    cp $GUARDIANS_REST_KEY_FILE $GUARDIANS_REST_KEYSTORE_DIR/$GUARDIANS_REST_KEY_FILE

    bash generatePkcs12Key.sh "$passwordKeystoreWebapp" \
        "--alias=$GUARDIANS_WEBAPP_KEY_ALIAS" \
        "--file=$GUARDIANS_WEBAPP_KEY_FILE"
    cp $GUARDIANS_WEBAPP_KEY_FILE $GUARDIANS_WEBAPP_KEYSTORE_DIR/$GUARDIANS_WEBAPP_KEY_FILE

    echo "Cloning guardians rest release $GUARDIANS_REST_RELEASE"
    output="$($GIT clone --single-branch -b $GUARDIANS_REST_RELEASE $GUARDIANS_REST_REPO 2>&1)"
    [ $? -eq 0 ] || showUnexpectedError "$output"


    echo "Configuring the rest service"

    # Configure the application.properties file
    propertiesFile="$GUARDIANS_REST_DIR_NAME/$GUARDIANS_REST_PROPERTIES_FILE"
    $PYTHON replace.py $propertiesFile \
        "${TOKEN_MYSQL_DB_NAME}=${MYSQL_DB_NAME}" \
        "${TOKEN_MYSQL_USERNAME}=${MYSQL_USERNAME}" \
        "${TOKEN_MYSQL_PASSWORD}=${passwordMysql}" \
        \
        "${TOKEN_KEYSTORE_FILE}=${GUARDIANS_REST_KEYSTORE_DIR}/${GUARDIANS_REST_KEY_FILE}" \
        "${TOKEN_KEYSTORE_ALIAS}=${GUARDIANS_REST_KEY_ALIAS}" \
        "${TOKEN_KEYSTORE_PASSWORD}=${passwordKeystoreRest}" \
        \
        "${TOKEN_LOG_FILE}=${GUARDIANS_REST_LOG_FILE}" \
        \
        "${TOKEN_BASIC_AUTH_USERNAME}=${BASIC_AUTH_USERNAME}" \
        "${TOKEN_BASIC_AUTH_PASSWORD}=${passwordBasicAuth}" \
        \
        "${TOKEN_SCHEDULER_COMMAND}=${SCHEDULER_COMMAND}" \
        "${TOKEN_SCHEDULER_ENTRY_POINT}=${SCHEDULER_ENTRY_POINT}" \
        "${TOKEN_SCHEDULER_CONF_ARG}=${SCHEDULER_CONF_DIR_ARG}${SCHEDULER_CONF_DIR}"
    cp $propertiesFile $GUARDIANS_REST_CONF_DIR/$GUARDIANS_REST_PROPERTIES_FILE

    # Configure the database
    $PYTHON replace.py $GUARDIANS_REST_SQL_CONFIGURE \
        "${TOKEN_MYSQL_DB_NAME}=${MYSQL_DB_NAME}" \
        "${TOKEN_MYSQL_USERNAME}=${MYSQL_USERNAME}" \
        "${TOKEN_MYSQL_PASSWORD}=${passwordMysql}"
    $MYSQL < $GUARDIANS_REST_SQL_CONFIGURE
    $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_CREATE
    $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_POPULATE_ALLOWED_SHIFTS
    if [ ! $PRELOAD_DOCTORS_AND_SHIFT_CONFIGS -eq 0 ]; then
        $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_POPULATE_DOCTORS
        $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_POPULATE_SHIFT_CONFIGS
    fi

    # Copy the executable file to its corresponding destination
    guardiansRestJar="$(ls $GUARDIANS_REST_DIR_NAME | grep $GUARDIANS_JAR_PREFIX)"
    cp $GUARDIANS_REST_DIR_NAME/$guardiansRestJar $GUARDIANS_REST_EXEC_DIR/$guardiansRestJar

    # Configure the service file
    cp $GUARDIANS_SERVICE_FILE /etc/systemd/system/$GUARDIANS_SERVICE_FILE
    $PYTHON replace.py /etc/systemd/system/$GUARDIANS_SERVICE_FILE \
        "${TOKEN_APPLICATION_PROPERTIES}=${GUARDIANS_REST_CONF_DIR}/${GUARDIANS_REST_PROPERTIES_FILE}" \
        "${TOKEN_GUARDIANS_USER}=${GUARDIANS_REST_USER}" \
        "${TOKEN_GUARDIANS_ENTRY_POINT}=${GUARDIANS_REST_EXEC_DIR}/${guardiansRestJar}"
    systemctl daemon-reload
    # The service will run on startup
    systemctl enable guardians


    echo "Cloning scheduler release $SCHEDULER_RELEASE"
    output="$($GIT clone --single-branch -b $SCHEDULER_RELEASE $SCHEDULER_REPO 2>&1)"
    [ $? -eq 0 ] || showUnexpectedError "$output"


    echo "Configuring the scheduler"

    # Install dependencies using pip
    output="$($SCHEDULER_COMMAND -m pip install -r $SCHEDULER_DIR_NAME/requirements.txt 2>&1)"
    [ $? -eq 0 ] || showUnexpectedError "$output"

    # Configure the logging file
    $PYTHON replace.py $SCHEDULER_DIR_NAME/$SCHEDULER_REPO_CONF_DIR/$SCHEDULER_CONF_LOGGING_FILE_NAME \
        "${TOKEN_SCHEDULER_LOG_FILE}=${SCHEDULER_LOG_FILE}"
    # Copy the configuration files to its directory
    cp $SCHEDULER_DIR_NAME/$SCHEDULER_REPO_CONF_DIR/* $SCHEDULER_CONF_DIR/

    # Scheduler source scripts
    cp $SCHEDULER_DIR_NAME/$SCHEDULER_REPO_SRC_DIR/* $SCHEDULER_EXEC_DIR/


    echo "Cloning webapp release $GUARDIANS_WEBAPP_RELEASE"
    output="$($GIT clone --single-branch -b $GUARDIANS_WEBAPP_RELEASE $GUARDIANS_WEBAPP_REPO 2>&1)"
    [ $? -eq 0 ] || showUnexpectedError "$output"


    echo "Configuring the webapp"

    # Configure the application.properties file
    webappPropertiesFile="$GUARDIANS_WEBAPP_DIR_NAME/$GUARDIANS_WEBAPP_PROPERTIES_FILE"
    $PYTHON replace.py $webappPropertiesFile \
        "${TOKEN_KEYSTORE_FILE}=${GUARDIANS_WEBAPP_KEYSTORE_DIR}/${GUARDIANS_WEBAPP_KEY_FILE}" \
        "${TOKEN_KEYSTORE_ALIAS}=${GUARDIANS_WEBAPP_KEY_ALIAS}" \
        "${TOKEN_KEYSTORE_PASSWORD}=${passwordKeystoreWebapp}" \
        \
        "${TOKEN_LOG_FILE}=${GUARDIANS_WEBAPP_LOG_FILE}" \
        \
        "${TOKEN_TRUSTSTORE_FILE}=${GUARDIANS_REST_KEYSTORE_DIR}/${GUARDIANS_REST_KEY_FILE}" \
        "${TOKEN_TRUSTSTORE_PASSWORD}=${passwordKeystoreRest}" \
        \
        "${TOKEN_BASIC_AUTH_USERNAME}=${BASIC_AUTH_USERNAME}" \
        "${TOKEN_BASIC_AUTH_PASSWORD}=${passwordBasicAuth}" \
        \
        "${TOKEN_WEBAPP_USERNAME}=${webappUsername}" \
        "${TOKEN_WEBAPP_PASSWORD}=${webappPassword}"
    cp $webappPropertiesFile $GUARDIANS_WEBAPP_CONF_DIR/$GUARDIANS_WEBAPP_PROPERTIES_FILE

    # Copy the executable file to its corresponding destination
    guardiansWebappJar="$(ls $GUARDIANS_WEBAPP_DIR_NAME | grep $GUARDIANS_WEBAPP_JAR_PREFIX)"
    cp $GUARDIANS_WEBAPP_DIR_NAME/$guardiansWebappJar $GUARDIANS_WEBAPP_EXEC_DIR/$guardiansWebappJar

    # Configure the service file
    cp $GUARDIANS_WEBAPP_SERVICE_FILE /etc/systemd/system/$GUARDIANS_WEBAPP_SERVICE_FILE
    $PYTHON replace.py /etc/systemd/system/$GUARDIANS_WEBAPP_SERVICE_FILE \
        "${TOKEN_APPLICATION_PROPERTIES}=${GUARDIANS_WEBAPP_CONF_DIR}/${GUARDIANS_WEBAPP_PROPERTIES_FILE}" \
        "${TOKEN_GUARDIANS_USER}=${GUARDIANS_WEBAPP_USER}" \
        "${TOKEN_GUARDIANS_ENTRY_POINT}=${GUARDIANS_WEBAPP_EXEC_DIR}/${guardiansWebappJar}"
    systemctl daemon-reload
    # The service will run on startup
    systemctl enable guardiansWebapp


    echo "Changing ownerships of needed directories"

    userAndGroupRest="${GUARDIANS_REST_USER}:${GUARDIANS_REST_USER}"
    userAndGroupWebapp="${GUARDIANS_WEBAPP_USER}:${GUARDIANS_WEBAPP_USER}"
    userRestAndGroupShared="${GUARDIANS_REST_USER}:${GUARDIANS_SHARED_GROUP}"
    chown -R $userAndGroupRest $LOG_DIR
    chown -R $userAndGroupWebapp $LOG_DIR_WEBAPP

    chown -R $userAndGroupRest $GUARDIANS_REST_CONF_DIR
    chown -R $userRestAndGroupShared $GUARDIANS_REST_KEYSTORE_DIR
    chown -R $userAndGroupRest $GUARDIANS_REST_EXEC_DIR

    chown -R $userAndGroupRest $SCHEDULER_CONF_DIR
    chown -R $userAndGroupRest $SCHEDULER_EXEC_DIR

    chown -R $userAndGroupWebapp $GUARDIANS_WEBAPP_CONF_DIR
    chown -R $userAndGroupWebapp $GUARDIANS_WEBAPP_KEYSTORE_DIR
    chown -R $userAndGroupWebapp $GUARDIANS_WEBAPP_EXEC_DIR


    echo "Changing permissions of needed directories and files"

    # The config and keystore directory will not be changed, so only 
    # permissions to navigate and list files are needed
    chmod 550 $GUARDIANS_REST_CONF_DIR
    chmod 550 $GUARDIANS_REST_KEYSTORE_DIR
    chmod 550 $SCHEDULER_CONF_DIR
    chmod 550 $GUARDIANS_WEBAPP_CONF_DIR
    chmod 550 $GUARDIANS_WEBAPP_KEYSTORE_DIR

    # The config files and the keystore files only have to be read
    chmod 440 $GUARDIANS_REST_CONF_DIR/$GUARDIANS_REST_PROPERTIES_FILE
    chmod 440 $GUARDIANS_REST_KEYSTORE_DIR/$GUARDIANS_REST_KEY_FILE
    chmod 440 $SCHEDULER_CONF_DIR/*
    chmod 440 $GUARDIANS_WEBAPP_CONF_DIR/$GUARDIANS_WEBAPP_PROPERTIES_FILE
    chmod 440 $GUARDIANS_WEBAPP_KEYSTORE_DIR/$GUARDIANS_WEBAPP_KEY_FILE

    # Navigate, list and create files in these directories
    chmod 770 $LOG_DIR
    chmod 770 $LOG_DIR_WEBAPP
    chmod 770 $GUARDIANS_REST_EXEC_DIR
    chmod 770 $SCHEDULER_EXEC_DIR
    chmod 770 $GUARDIANS_WEBAPP_EXEC_DIR

    # The main jar only has to be read
    chmod 440 $GUARDIANS_REST_EXEC_DIR/$guardiansRestJar
    # The scheduler scripts only need to be read
    chmod 440 $SCHEDULER_EXEC_DIR/*.py
    chmod 440 $GUARDIANS_WEBAPP_EXEC_DIR/$guardiansWebappJar


    cleanUp

    echo
    echo "To start the services, use 'systemctl start guardians' and "
    echo "'systemctl start guardiansWebapp'."
}

main

# Restore the original working directory
cd $CURR_DIR