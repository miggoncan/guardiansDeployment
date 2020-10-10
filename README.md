# Guardians deployment
This respository contains the scripts needed to deploy the [guardians application](https://github.com/miggoncan/guardiansRESTinterface).

## Dependencies

### Application dependencies

 1. Python3.7
 2. MySQL Server
 3. OpenJDK-1.8

### Setup dependencies

 1. Git
 2. MySQL command line client
 
### Installing the dependencies

These dependencies can be installed with a package manager such as `apt-get`:
```
apt-get update
apt-get install python3.7
apt-get install python3-pip
apt-get install mysql-server
apt-get install openjdk-8-jdk
apt-get install git
```

The `mysql-server` package also includes the command line tool `mysql` needed to 
connect to the database.

Note that it is highly recommended configuring the database by running:
```
secure_mysql_installation
```

## Configuration

The `config.sh` file contains the constants that will be used to deploy
the service. For example, the version of the guardians rest service to 
be installed, or the path to which the configuration files will be moved.

The contents of the file are self-explanatory.

## Deployment

To deploy the application, we can clone this repository:
```
git clone https://github.com/miggoncan/guardiansDeployment.git
```
Then, we may want to change the version being installed. To do that, change the  values 
of `GUARDIANS_REST_RELEASE`, `SCHEDULER_RELEASE` and `GUARDIANS_WEBAPP_RELEASE` in the 
`config.sh` file to the desired values. For example:
```
GUARDIANS_REST_RELEASE="v1.1.0"
SCHEDULER_RELEASE="v0.1.4"
GUARDIANS_WEBAPP_RELEASE="v1.0.0"
```
Lastly, we can run the `install.sh` script:
```
bash guardiansDeployment/install.sh
```
Note the `install.sh` script needs root privileges.

If we want to change the deployment configuration, we can change the contents of `config.sh`. 
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

Tested on Ubuntu 18.04 LTS.
