## Introduction
For this demo docker container, this README describes the various components of that should get updated regularly and how to perform the updates.  After any update is done, test it by doing a `git pull` or `git clone` of this [repo](git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git), then run the [`build.sh`](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container#step-1-build-the-docker-image) script and then [start](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container#step-2-start-the-docker-container) the docker container and test the java, python, scala and ODBC [applications](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications) to ensure all work with the sample data.  You will need a functioning  Db2 Event Store that has haproxy setup for this testing.

## Event Store versions
For new versions of Event Store add them in this file while keeping the same pattern of the other versions of Event Store <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/es-releases.json <br>
After this change do a git pull of this repo and re-build the docker container.  

Also edit this line to put in new version <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/build.sh#L3 <br>

And this file <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-container.sh

## SBT
SBT is the Simple Build Tool (SBT).  The best practice is to get notifiied of new releases selecting `Watch` ... `Custom` ...  `Releases` of this git repo <br>
https://github.com/sbt/sbt/releases <br>
When a new version SBT comes out update these 2 lines <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L24 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh#L25 <br>

Update manual instructions here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/README.md#sbt-setup


## Spark
Watch for new releases here https://github.com/apache/spark-website and get notifiied of new releases selecting `Watch` ... `Custom` ...  `Releases` of this git repo <br>
Updates of spark versions is done here
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L13 <br>
If you modify the IBM jars that have spark then make sure the  `ELSIB` line changed in these <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/JavaApplication/runjavaExample#L7 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/PythonApplication/runpythonExample#L2 <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/ScalaApplication/runscalaExample#L5 <br>

Hardcoded version here as the variable stopped working <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-container.sh#L15

Also update this page <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#specific-applicaition-option

Also update Docker file 
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L51
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L52

Place the spark media file to <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/spark_media_package <br>
You will need to do the following to do this
```
cd ~
git clone git@github.com:IBMProjectEventStore/db2eventstore-IoT-Analytics.git
```
copy the file to
```
~/db2eventstore-IoT-Analytics/spark_media_package
```
since the file is over 100 MB you need to use `git-lfs`, so run these commands replace `spark-2.4.8-bin-hadoop2.6.tgz` with your new spark media file
```
yum install -y git-lfs
git install lfs
git lfs track "spark-2.4.8-bin-hadoop2.6.tgz"
gid add .gitattributes
git add spark-2.4.8-bin-hadoop2.6.tgz
git commit -m "adding new spark media file"
git pull
git push
```
This file and directory name is now hard coded in a few places, so if it changes you must update
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L52
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L53
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L54

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

When a new Long Term Support (LTS) version is released update this file in this line <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/rest/install.sh#L4 <br>
Go to this [link](https://github.com/nodesource/distributions#installation-instructions-1) to determine how to modify the above line for new versions of Node.js (our docker image is UBI 8 which is based off Red Hat 8). <br>
But when you build the container this will pull the latest node.js version from LTS branch specified.  So we only configure the Node.js
release number in the file, so `setup_16.x` tells our script to install release 16 of Node.js and the script will install the latest version of Node.js 16, for example on Sept 22, 2021 this was version `v16.10.0` as determined by `node -v` command inside the IoT demo docker container.

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
The Db2 driver is used for the ODBC test.

To update the docker image with new versions of the  IBM Data Server Driver, download it as described [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#odbcdb2cli-setup ), clone this repo on a linux vm, then copy the file to
  `db2eventstore-IoT-Analytics/ibm_data_server_driver_package`, delete the old driver, do the following in git
  ```
  # add your public ssh key from your linux vm to your account on github.com (https://github.com/settings/keys)
  # below put your name and email address you use to log into github.com
  git config --global user.name James Stroud
  git config --global user.email james.jstroud@gmail.com
  git pull
  cd db2eventstore-IoT-Analytics/ibm_data_server_driver_package
  git add <new ds driver filename> 
  git commit -a -m "put comments about the change - such as update to new db2 dsdriver version xxxx"
  git pull
  git push
  ```
  
  edit https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L54 and point to the new file

## Operating System 
Jim Stroud upgraded from UBI 7 to [UBI 8](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L1) on June 13, 2021, when that was done, we had to move any Red Hat version 7 (el7) rpms to version 8 (el8). <br>
This was done here <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L34

## Scala
This container is on the last release of the Scala 2.11.x branch, which is `2.11.12`  See here  https://www.scala-lang.org/download/scala2.html <br>
Event Store 2.x is still on using `2.11.8`.  If there is another release of Scala 2.11.x the update is done here <br> https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh  <br>
Before making the change verify the new rpm is able to be downloaded from <br>
http://downloads.typesafe.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.${PKGTYPE} <br>
If not use the lightbend as that is what the scala-lang.org website points to now.  Here is an example of the lightbend download <br>
https://downloads.lightbend.com/scala/2.11.12/scala-2.11.12.rpm

Also update rpms on this page 
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications#specific-applicaition-option

To verify the change, inside the demo container run this command
```
scala -version
```
The output will show
```
cat: /usr/lib/jvm/java-1.8.0-openjdk/release: No such file or directory
Scala code runner version 2.11.12 -- Copyright 2002-2017, LAMP/EPFL
```
## Java
Java 1.8 is automatically updated to the latest version upon building the docker container.  This is done via https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh#L12 and https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh#L13

## Outstanding items
There is another Simple Build Tool (SBT) used in this container.  I only updated the one mentioned above.  There is a much older version that is in use here that I do not know how to update.  It was updated in htap-ng repo.  If I can find that pull request I will add it here. This may be pull request https://github.ibm.com/htap-ng/db2-sirius/pull/196
