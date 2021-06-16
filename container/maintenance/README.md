## Introduction
For this demo docker container, this README describes the various components of that should get updated regularly and how to perform the updates.  After any update is done, test it by doing a `git pull` or `git clone` of this [repo](git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git), then run the [`build.sh`](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container#step-1-build-the-docker-image) script and then [start](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container#step-2-start-the-docker-container) the docker container and test the java, python, scala and ODBC [applications](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications) to ensure all work with the sample data.  You will need a functioning  Db2 Event Store that has haproxy setup for this testing.

## SBT
SBT is the Simple Build Tool (SBT).  The best practice is to get notifiied of new releases selecting `Watch` ... `Custom` ...  `Releases` of this git repo <br>
https://github.com/sbt/sbt/releases <br>
When a new version SBT comes out update these 2 lines <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L24 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L25 <br>

Update manual instructions here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/README.md#sbt-setup


## Spark
This is done here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L13 <br>
If you modify the IBM jars that have spark then make sure the  `ELSIB` line changed in these <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/JavaApplication/runjavaExample#L7 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/PythonApplication/runpythonExample#L2 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/ScalaApplication/runscalaExample#L5 <br>

## Python
This is done here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-python.sh#L9 <br>
Python upgrades to new versions such as 3.6.x to 3.7.x can break functionality.  So it not safe to ugprade to versions as such, but moving from 3.6.x to 3.6.y is typically is safe to do. 

Update manual instructions here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/README.md#python-setup

## Node.js
Node.js is uses for the REST Service.  The best practice is to get notifiied of new releases selecting `Watch` ... `Custom` ...  `Releases`  of this git repo <br>
https://github.com/nodejs/node/releases <br>
Also look at this page to verify we are on the Long Term Support (LTS) version <br>
https://nodejs.org/en/about/releases/ <br>

When security updates are relased or a new Long Term Support (LTS) version is released update this file in this line <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/rest/install.sh#L4

## Node Packages 
The only node.js package is called `request` and is already at the lastet and last release as the package is now deprecated <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/rest/package.json#L7

Replacement should be either [axios](https://github.com/axios/axios) or [got](https://github.com/sindresorhus/got)  Also see [here](https://nodesource.com/blog/express-going-into-maintenance-mode) 



## Db2 Drivers
The actual Db2 drivers are in this folder <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/ibm_data_server_driver_package <br>
The instructions to populate that folder are here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup <br>

and are referenced here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L54
So if a new version of Db2 driver is available, download it, put in the folder above, and modify the Dockerfile to ensure it is referenced properly.
The Db2 driver is used for the ODBC test

## Operating System 
Jim Stroud upgraded from UBI 7 to [UBI 8](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L1) on June 13, 2021, when that was done, we had to move any Red Hat version 7 (el7) rpms to version 8 (el8). <br>
This was done here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L34

## Scala
This container is on the last release of the Scala 2.11.x branch, which is `2.11.12`  See here  https://www.scala-lang.org/download/scala2.html <br>
Event Store 2.x is still on using `2.11.8`.  If there is another release of Scala 2.11.x the update is done here https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh  Before making the change verify the new rpm is able to be downloaded from <br>
http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.${PKGTYPE} <br>
If not use the lightbend as that is what the scala-lang.org website points to now.  Here is an example of the lightbend download <br>
https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.rpm
