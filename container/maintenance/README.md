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

Also update Docker file <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L51
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L52


This file and directory name is now hard coded in a few places, so if it changes you must update, this is pulling from
an Amazon Web Services (AWS) linux server in James Stroud's personal account that has nginx running as the web server <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L49 <br>
If this wget from spark media fails just replace line above with line below to pull from archive.apache.org <br>
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L53 <br>
Inside the IoT container (when connecting with dockershell), this directory
```
/spark_home
```
should have directories and files that like so when the spark media has been copied successfully into the container
```
root@adc807075d94 spark_home]# ls -ltr
total 104
drwxr-xr-x 2 501 1000    42 May  8  2021 yarn
drwxr-xr-x 4 501 1000    38 May  8  2021 kubernetes
drwxr-xr-x 4 501 1000    29 May  8  2021 examples
-rw-r--r-- 1 501 1000   187 May  8  2021 RELEASE
drwxr-xr-x 2 501 1000  4096 May  8  2021 licenses
drwxr-xr-x 5 501 1000    50 May  8  2021 data
drwxr-xr-x 2 501 1000   230 May  8  2021 conf
drwxr-xr-x 2 501 1000  4096 May  8  2021 bin
-rw-r--r-- 1 501 1000  3756 May  8  2021 README.md
-rw-r--r-- 1 501 1000 42919 May  8  2021 NOTICE
-rw-r--r-- 1 501 1000 21371 May  8  2021 LICENSE
drwxr-xr-x 2 501 1000  4096 May  8  2021 sbin
drwxr-xr-x 7 501 1000   275 May  8  2021 python
drwxr-xr-x 3 501 1000    17 May  8  2021 R
drwxr-xr-x 2 501 1000 12288 Sep  9 14:13 jars
```
Since I found the apache.org for downloads of the `spark-2.4.8-bin-hadoop2.6.tgz` to be unreliable, I stood up an Amazon linux server, installed nginx, then copied
the spark hadoop media to this aws instance to allow for faster and reliable downloads.  Here is how I set this up. <br>
Get  a free tier amazon linux 2 ami as a `spot instance`  lot into the container, you must login as the `ec2-user` and open up ports 22, 80 & 443 from the internet
then run these commands
```
sudo su -
yum update -y
sudo amazon-linux-extras list | grep nginx
yum -y install nginx
amazon-linux-extras enable nginx1
yum clean metadata
yum install -y nginx
systemctl status nginx
systemctl start nginx
systemctl enable  nginx
```

Copy or download the spark-2.4.8-bin-hadoop2.6.tgz to `/home/ec2-user`
you can get the file from https://archive.apache.org/dist/spark/spark-2.4.8/spark-2.4.8-bin-hadoop2.6.tgz
here is how to do this and to copy this file to the nginx doc root

```
cd /home/ec2-user
wget https://archive.apache.org/dist/spark/spark-2.4.8/spark-2.4.8-bin-hadoop2.6.tgz
cp spark-2.4.8-bin-hadoop2.6.tgz /usr/share/nginx/html/
```

Now run the following commands to enable automatic package and operating system updates to 
```
yum install yum-cron -y
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
sed -i "s/apply_updates = no/apply_updates = yes/g" /etc/yum/yum-cron.conf
```


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
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L60
So if a new version of Db2 driver is available, download it, put in the folder above, and modify the Dockerfile to ensure it is referenced properly. The Db2 driver is called `IBM Data Server Driver Package` on IBM support pages and also referred to as `Information Management, IBM Data Server Client Packages (Linux 64-bit,x86_64)` and is roughly 75 MB in size.
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
  git push
  ```
  
  edit https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/Dockerfile#L60 and point to the new file
  
  To remove an the old db2 ds driver after you updated the repo with the new one, do the following
  ```
  git pull
  cd db2eventstore-IoT-Analytics/ibm_data_server_driver_package
  git rm <od  ds driver filename> 
  git commit -m "put comments about the change - such as remove old  db2 dsdriver version xxxx"
  git push
  ```
  if the file we are deleting is `v11.5.6_linuxx64_dsdriver.tar.gz`, then the git rm command would be
  ```
  git rm v11.5.6_linuxx64_dsdriver.tar.gz
  ```


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
### SBT
There is another Simple Build Tool (SBT) used in this container.  I only updated the one mentioned above.  There is a much older version that is in use here that I do not know how to update.  It was updated in htap-ng repo.  If I can find that pull request I will add it here. This may be pull request https://github.ibm.com/htap-ng/db2-sirius/pull/196

### Spark Client
The spark client is stored in aws amazon linux and is pulled down via wget.  This 224 MB file is now in aws ec2 free instance, ideally we should put this in artifactory or some other site that is reliable and modify the `setup-spark.sh` script accordingly.  The file is `spark-2.4.8-bin-hadoop2.6.tgz` and this container pulls from `ec2-18-221-253-80.us-east-2.compute.amazonaws.com` host on aws the file is under `/usr/share/nginx/html` directory. The amazon linux 2 instance is running nginx.

The original scripts used to perform a wget against a maven web site to get this file, but that was unreliable and took too long.  This is the original method
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L53
where line 
https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh#L49
is.  Using line 49 is much faster and more reliable.

