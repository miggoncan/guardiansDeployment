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

By default, the application will be deployed as:
```
/etc/
 |- guardians/ # The REST service’s configuration directory
 |   |- application.properties
 |   |- keystore/
 |   |   |- guardiansRest.p12
 |   |- scheduler/ # The Scheduler’s configuration directory
 |   |   |- scheduler.json
 |   |   |- logging.json
 |- guardiansWebapp/ # The Web server’s configuration directory
 |   |- application.properties
 |   |- keystore/
 |   |   |- guardiansWebapp.p12
 |- systemd/system/
 |   |- guardians.service        # Systemd service files for both
 |   |- guardiansWebapp.service  # the REST service and Web server
/var/log/
 |- guardians/ # The REST service’s and scheduler’s logging dir
 |   |- guardians.log
 |   |- scheduler.log
 |- guardiansWebapp/ # The Web server’s logging directory
 |   |- guardiansWebapp.log
/usr/lib/
 |- guardians/
 |   |- guardians-vXXX.jar # The REST service’s jar file
 |   |- scheduler/ # The scheduler’s source directory
 |   |   |- main.py
 |   |   |- scheduler.py
 |- guardiansWebapp/
 |   |- guardiansWebapp-vXXX.jar # The Web server’s jar file
```

Note, the deployment has been configured for the ubuntu file system.
In case the application was to be deployed in a different file system,
edit the `config.sh` script.

Tested on Ubuntu 18.04 LTS.