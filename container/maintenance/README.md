## Introduction
This will describe the various components or pieces that should get updated regularly

## SBT
SBT is the Simple Build Tool (SBT).  The best practice is to subscribe to new releases of this repo
https://github.com/sbt/sbt/releases
When a new version SBT comes out update these 2 lines
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L24
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L25


## Spark
This is done here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L13
If you modify the IBM jars that have spark then make sure the  `ELSIB` line changed in these <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/JavaApplication/runjavaExample#L7
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/PythonApplication/runpythonExample#L2
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/ScalaApplication/runscalaExample#L5

## Python
This is done here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-python.sh#L9
Python upgrades to new versions such as 3.6.x to 3.7.x can break functionality.  So it not safe to ugprade to versions as such, but moving from 3.6.x to 3.6.y is typically is safe to do.

## Node.js
Node.js is uses for the REST Service.  The best practice is to subscribe to new releases of thisrepos
https://github.com/nodejs/node/releases <br>
The only node.js package is called `request` and is already at the lastet and last release as the package is now deprecated
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/rest/package.json#L7

When security updates are relased or a new Long Term Support (LTS) version is released update this file in this line
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/rest/install.sh#L4

## Db2 Drivers
The actual Db2 drivers are in this folder <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/ibm_data_server_driver_package
The instructions to populate that folder are here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup

and are referenced here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L54
So if a new version of Db2 driver is available, download it, put in the folder above, and modify the Dockerfile to ensure it is referenced properly.
The Db2 driver is used for the ODBC test

## Operating System 
Jim Stroud upgraded from UBI 7 to UBI 8 on June 13, 2021, when that was done, we had to move any Red Hat version 7 (el7) rpms to version 8 (el8).
This was done here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L34

