# Guardians deploment
This respository contains the scripts needed to deploy the [guardians application](https://github.com/miggoncan/guardiansRESTinterface).

## Dependencies

### Application dependencies

 1. Python3.7
 2. MySQL Server
 3. OpenJDK-1.8

### Installation dependencies

 1. Git
 2. MySQL command line client

## Configuration

The `config.sh` file contains the constants that will be used to deploy
the service. For example, the version of the guardians rest service to 
be installed, or the path to which the configuration files will be moved.

The contents of the file are self-explanatory.

## Deployment

To install deploy the application, just run `bash install.sh`.

Note, the deployment has been configured for the ubuntu file system.
In case the application was to be deployed in a different file system,
edit the `config.sh` script.

Tested on Ubuntu 18.04 LTS.