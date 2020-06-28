#!/bin/bash
####################################################################
#
# File: generatePkcs12Key.sh
#
# Description: This script is used to generate a PKCS12 key using
#     the tool 'keytool' shipped with Java Runtime Environment
#
# Usage: 
#     bash generatePkcs12Key.sh <password> [--alias=<alias>] [--file=<file>]
#
#     This programm has one required argument:
#         <password>:
#             The password used to encrypt the key
#
#     This programm has two optional arguments:
#         --alias=<value>:
#             The value is the alias of the generated key
#         --file=<value>:
#             The value is the path to the output file
#
# Author: miggoncan 
#
# Date: 8-june-2020
#
#####################################################################

ALIAS=guardians
FILE=guardians.p12

ALG=RSA
KEYSIZE=2048
STORETYPE=PKCS12
VALIDITY=3650

NAME=miggoncan
ORG_UNIT=Unknown
ORG_NAME="Universidad de Sevilla"
CITY=Sevilla
STATE=Sevilla
COUNTRY=ES

printHelp(){
    if [ $# -gt 0 ]; then
        echo "Unknown option '$1'"
    fi

    echo "Usage:"
    echo "  $0 <password> [--alias=<alias>] [--file=<file>]"
    echo ""
    echo "    <password>"
    echo "      The password used to encrypt the key"
    echo ""
    echo "    --alias=<alias>"
    echo "      The alias used to generate the keypair"
    echo ""
    echo "    --file=<file>"
    echo "      The file that will contain the generated keypair"
    echo ""
    echo "    -h, --help"
    echo "      Show this information"
}

parseArgs() {
    PASSWORD="$1"
    shift # Move on to next argument
    while [ $# -gt 0 ]; do
        key="$1"

        case $key in
            --alias=*)
                ALIAS=${key#*=} # Value after the equal sign
                shift # Shift to next argument
                ;;
            --file=*)
                FILE=${key#*=}
                shift
                ;;
            -h|--help)
                printHelp && exit 1
                ;;
            *)  # Unkown option
                printHelp $key && exit 1
                ;;
        esac
    done
}

if [ $# -eq 0 ]; then
    printHelp && exit 1
fi

parseArgs $*

if [ -f $FILE ]; then
 echo "[WARNING] the provided file already exists"
fi

echo "Generating key with:"
echo "    Alias=$ALIAS, File=$FILE"
echo "    CN=$NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"

keytool -genkeypair -alias "$ALIAS" -keyalg "$ALG" -keysize "$KEYSIZE" \
    -storetype "$STORETYPE" -keystore "$FILE" -validity "$VALIDITY" \
    -storepass "$PASSWORD" \
    -dname "CN=$NAME, OU=$ORG_UNIT, O=$ORG_NAME, L=$CITY, ST=$STATE, C=$COUNTRY"
