#!/bin/bash
####################################################################
#
# File: install.sh
#
# Description: TODO
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


main () {
    # Exit if the user does not have sudo privileges
    if [[ $(id -u) -ne 0 ]]; then
        echo "This script needs to be run with root privileges"
        echo "Try using 'sudo $USAGE' or 'su -c \"$USAGE\"'"
        exit 1
    fi

    # Check the needed commands exist. If any does not exist, the 
    # program will exit with error code 1
    is_bin_in_path $MYSQL || notInstalled $MYSQL
    is_bin_in_path $GIT || notInstalled $GIT
    is_bin_in_path $PYTHON || notInstalled $PYTHON

    echo "Creating users: $GUARDIANS_REST_USER"
    useradd --no-create-home $GUARDIANS_REST_USER
    usermod --lock $GUARDIANS_REST_USER

    echo "Creating needed directories"
    mkdir -p $GUARDIANS_REST_CONF_DIR
    mkdir -p $GUARDIANS_REST_KEYSTORE_DIR
    mkdir -p $LOG_DIR
    mkdir -p $GUARDIANS_REST_EXEC_DIR

    echo "Generating passwords"
    passwordMysql="$($GEN_PASSWORD_COMMAND)"
    passwordKeystore="$($GEN_PASSWORD_COMMAND)"
    passwordBasicAuth="$($GEN_PASSWORD_COMMAND)"

    echo "Generating the key for guardians rest service"
    bash genaratePkcs12Key.sh $passwordKeystore \
        --alias=$GUARDIANS_REST_KEY_ALIAS \
        --file=$GUARDIANS_REST_KEY_FILE
    cp $GUARDIANS_REST_KEY_FILE $GUARDIANS_REST_KEYSTORE_DIR/$GUARDIANS_REST_KEY_FILE

    echo "Cloning guardians rest release $GUARDIANS_REST_RELEASE"
    $GIT clone --single-branch -b $GUARDIANS_REST_RELEASE $GUARDIANS_REST_REPO

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
        "${TOKEN_KEYSTORE_PASSWORD}=${passwordKeystore}" \
        \
        "${TOKEN_LOG_FILE}=${GUARDIANS_REST_LOG_FILE}" \
        \
        "${TOKEN_BASIC_AUTH_USERNAME}=${BASIC_AUTH_USERNAME}" \
        "${TOKEN_BASIC_AUTH_PASSWORD}=${passwordBasicAuth}" \
        \
        "${TOKEN_SCHEDULER_COMMAND}=${SCHEDULER_COMMAND}" \
        "${TOKEN_SCHEDULER_ENTRY_POINT}=\"${SCHEDULER_ENTRY_POINT} ${SCHEDULER_CONF_DIR_ARG}${SCHEDULER_CONF_DIR}\""
    cp $propertiesFile $GUARDIANS_REST_CONF_DIR/$GUARDIANS_REST_PROPERTIES_FILE

    # Configure the database
    $PYTHON replace.py $GUARDIANS_REST_SQL_CONFIGURE \
        "${TOKEN_MYSQL_DB_NAME}=${MYSQL_DB_NAME}" \
        "${TOKEN_MYSQL_USERNAME}=${MYSQL_USERNAME}" \
        "${TOKEN_MYSQL_PASSWORD}=${passwordMysql}"
    $MYSQL < $GUARDIANS_REST_SQL_CONFIGURE
    $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_CREATE
    $MYSQL $MYSQL_DB_NAME < $GUARDIANS_REST_SQL_POPULATE_ALLOWED_SHIFTS

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

    # TODO configure scheduler

    # TODO configure the webapp

    echo "Changing permissions and ownerships of needed directories"
    userAndGroup="${GUARDIANS_REST_USER}:${GUARDIANS_REST_USER}"
    chown -R $userAndGroup $GUARDIANS_REST_CONF_DIR
    chown -R $userAndGroup $GUARDIANS_REST_KEYSTORE_DIR
    chown -R $userAndGroup $LOG_DIR
    chown -R $userAndGroup $GUARDIANS_REST_EXEC_DIR
    # The config and keystore directory will not be changed, so only 
    # permissions to navigate and list files are needed
    chmod 550 $GUARDIANS_REST_CONF_DIR
    chmod 550 $GUARDIANS_REST_KEYSTORE_DIR
    # The config file and the keystore file only have to be read
    chmod 440 $GUARDIANS_REST_CONF_DIR/$GUARDIANS_REST_PROPERTIES_FILE
    chmod 440 $GUARDIANS_REST_KEYSTORE_DIR/$GUARDIANS_REST_KEY_FILE
    # Navigate, list and create files in these directories
    chmod 770 $LOG_DIR
    chmod 770 $GUARDIANS_REST_EXEC_DIR
    # The main jar only has to be read
    chmod 440 $GUARDIANS_REST_EXEC_DIR/$guardiansRestJar

    echo "Cleaning up"
    rm -rf $GUARDIANS_REST_DIR_NAME
    rm -f $GUARDIANS_REST_KEY_FILE
}

main

# Restore the original working directory
cd $CURR_DIR