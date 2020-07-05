#!/bin/bash
####################################################################
#
# File: config.sh
#
# Description: This file contains the definiiton of contant values used
#     to install the guardians service
#
# Include it in another bash script with:
#     . config.sh
#
# Author: miggoncan
#
# Date: 28-june-2020
#
#####################################################################

###########################################
#
# Repositories
#
###########################################

# The repository and tagged version from which the rest service will 
# be installed
GUARDIANS_REST_RELEASE="v1.1.1"
GUARDIANS_REST_REPO="https://github.com/miggoncan/guardiansRESTinterface.git"
# The name of the directory that will be generated after a git clone
GUARDIANS_REST_DIR_NAME="guardiansRESTinterface"

# The repository and tagged version from which the scheduler will be
# installed
SCHEDULER_RELEASE="v0.1.4"
SCHEDULER_REPO="https://github.com/miggoncan/guardiansScheduler.git"
# The name of the directory that will be generated after a git clone
SCHEDULER_DIR_NAME="guardiansScheduler"
# The directory inside the git repo that contains the src scripts
SCHEDULER_REPO_SRC_DIR="src"
# The directory inside the git repo that contains the config files
SCHEDULER_REPO_CONF_DIR="config"

# The repository and tagged version from which the webapp will 
# be installed
GUARDIANS_WEBAPP_RELEASE="v1.0.0"
GUARDIANS_WEBAPP_REPO="https://github.com/miggoncan/guardiansWebapp.git"
# The name of the directory that will be generated after a git clone
GUARDIANS_WEBAPP_DIR_NAME="guardiansWebapp"

###########################################
#
# General configuration
#
###########################################

# Length of all the generated passwords
PASSWORD_LENGTH=20

# Set this value to '0' to NOT preload the doctors and their shift
# configurations. Set it to someething diffent to DO preload them.
# Note the ALLOWED SHIFTS will ALWAYS be preloaded
PRELOAD_DOCTORS_AND_SHIFT_CONFIGS=1

# The prefix with which the jar files start (used to get the name of 
# the jar files without knowing the version suffix). 
# E.g. guardians-1.0.0.jar -> We could use as a prefix "guardians"
GUARDIANS_JAR_PREFIX="guardians"
GUARDIANS_WEBAPP_JAR_PREFIX="guardiansWebapp"

# The user that will execute the guardians rest service daemon
GUARDIANS_REST_USER="guardiansRestUser"
# The user that will execute the guardiansWebapp daemon
GUARDIANS_WEBAPP_USER="guardiansWebappUser"
# A group the previous users will be part of
GUARDIANS_SHARED_GROUP="guardians"

MYSQL_DB_NAME="db_guardians"
MYSQL_USERNAME="guardiansUser"

# The username to authenticate to the rest service
BASIC_AUTH_USERNAME="guardiansUser"

# The python interpreter used to start the scheduler
SCHEDULER_COMMAND="python3.7"
# The argument used to indicate the scheduler its configuration directory
SCHEDULER_CONF_DIR_ARG="--configDir="

###########################################
#
# Directories and files
#
###########################################

# The directory where both the rest service and the scheduler will store 
# their logs
# Do NOT end this path with /
# E.d. use "/var/log/guardians" instead of "/var/log/guardians/"
LOG_DIR="/var/log/guardians"
LOG_DIR_WEBAPP="/var/log/guardiansWebapp"

# The directory that will contain the application.properties
GUARDIANS_REST_CONF_DIR="/etc/guardians"
# The directory that will contain the keystore
# Do NOT end this path with /
# E.g. use "/etc/guardians/keystore" instead of "/etc/guardians/keystore/"
GUARDIANS_REST_KEYSTORE_DIR="/etc/guardians/keystore"
# The directory that will contain the main JAR file of the REST service
GUARDIANS_REST_EXEC_DIR="/usr/lib/guardians"
GUARDIANS_REST_PROPERTIES_FILE="application.properties"
GUARDIANS_REST_LOG_FILE="$LOG_DIR/guardians.log"
GUARDIANS_SERVICE_FILE="guardians.service"
# The values needed to configure the public-private key for the rest service
GUARDIANS_REST_KEY_ALIAS="guardians"
GUARDIANS_REST_KEY_FILE="guardiansREST.p12"

# Files that contain the SQL needed to initialize the database
GUARDIANS_REST_SQL_DIR="$(dirname "$0")/${GUARDIANS_REST_DIR_NAME}/sql"
GUARDIANS_REST_SQL_CONFIGURE="${GUARDIANS_REST_SQL_DIR}/configure.sql"
GUARDIANS_REST_SQL_CREATE="${GUARDIANS_REST_SQL_DIR}/createTables.sql"
GUARDIANS_REST_SQL_POPULATE_ALLOWED_SHIFTS="${GUARDIANS_REST_SQL_DIR}/populateAllowedShifts.sql"
GUARDIANS_REST_SQL_POPULATE_DOCTORS="${GUARDIANS_REST_SQL_DIR}/populateDoctors.sql"
GUARDIANS_REST_SQL_POPULATE_SHIFT_CONFIGS="${GUARDIANS_REST_SQL_DIR}/populateShiftConfigs.sql"

# The directory where the configuration files of the scheduler will be 
#stored
SCHEDULER_CONF_DIR="/etc/guardians/scheduler"
# The directory where the scheduler scripts will be stored
SCHEDULER_EXEC_DIR="/usr/lib/guardians/scheduler"
# The script from which the scheduler will be started
SCHEDULER_ENTRY_POINT="$SCHEDULER_EXEC_DIR/main.py"
SCHEDULER_LOG_FILE="$LOG_DIR/scheduler.log"
SCHEDULER_CONF_LOGGING_FILE_NAME="logging.json"

# The directory that will contain the application.properties
GUARDIANS_WEBAPP_CONF_DIR="/etc/guardiansWebapp"
# The directory that will contain the keystore
# Do NOT end this path with /
# E.g. use "/etc/guardiansWebapp/keystore" instead of "/etc/guardiansWebapp/keystore/"
GUARDIANS_WEBAPP_KEYSTORE_DIR="/etc/guardiansWebapp/keystore"
# The directory that will contain the main JAR file of the Webapp
GUARDIANS_WEBAPP_EXEC_DIR="/usr/lib/guardiansWebapp"
GUARDIANS_WEBAPP_PROPERTIES_FILE="application.properties"
GUARDIANS_WEBAPP_LOG_FILE="$LOG_DIR_WEBAPP/guardiansWebapp.log"
GUARDIANS_WEBAPP_SERVICE_FILE="guardiansWebapp.service"
# The values needed to configure the public-private key for the webapp
GUARDIANS_WEBAPP_KEY_ALIAS="guardiansWebapp"
GUARDIANS_WEBAPP_KEY_FILE="guardiansWebapp.p12"

###########################################
#
# Tokens
#
###########################################

# These tokens will be replaced in the configuration files with their 
# correspondig values
# For example, TOKEN_MYSQL_PASSWORD will be replaced in the 
# configure.sql and application.properties files with the corresponding 
# generated password

TOKEN_MYSQL_DB_NAME="MYSQL_DB_NAME"
TOKEN_MYSQL_USERNAME="MYSQL_USERNAME"
TOKEN_MYSQL_PASSWORD="MYSQL_PASSWORD"

TOKEN_KEYSTORE_FILE="PATH_TO_KEYSTORE"
TOKEN_KEYSTORE_ALIAS="KEYSTORE_ALIAS"
TOKEN_KEYSTORE_PASSWORD="KEYSTORE_PASSWORD"

TOKEN_TRUSTSTORE_FILE="PATH_TO_TRUSTSTORE"
TOKEN_TRUSTSTORE_PASSWORD="TRUSTSTORE_PASSWORD"

TOKEN_LOG_FILE="PATH_TO_LOG_FILE"

TOKEN_BASIC_AUTH_USERNAME="BASIC_AUTH_USERNAME"
TOKEN_BASIC_AUTH_PASSWORD="BASIC_AUTH_PASSWORD"

TOKEN_WEBAPP_USERNAME="WEBAPP_USERNAME"
TOKEN_WEBAPP_PASSWORD="WEBAPP_PASSWORD"

TOKEN_SCHEDULER_COMMAND="SCHEDULER_COMMAND"
TOKEN_SCHEDULER_ENTRY_POINT="SCHEDULER_ENTRY_POINT"

TOKEN_GUARDIANS_ENTRY_POINT="GUARDIANS_ENTRY_POINT"
TOKEN_APPLICATION_PROPERTIES="PATH_TO_APPLICATION_PROPERTIES"
TOKEN_GUARDIANS_USER="GUARDIANS_USER"

TOKEN_SCHEDULER_LOG_FILE="PATH_TO_LOG_FILE"
TOKEN_SCHEDULER_CONF_ARG="ARGUMENT_TO_CHANGE_CONFIG_DIR"
