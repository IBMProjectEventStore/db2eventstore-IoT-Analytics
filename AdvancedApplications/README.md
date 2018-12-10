# Ingesting data using IBM Streams and running remote applications with IBM Db2 Event Store

## Introduction 

This document provides the information to set up your system and run the IBM Streams application
and remote acess appplications on Event Store. 

In this section we included mutiple directories, each with sample applications and step by step instructions to start ingesting data using IBM Streams and follow that with running external applications from your favourite access method. including Python, Java, Scala, or directly using JDBC. 

Follow these links to get to each of the sample applications:

* [Scala sample application to ingest and query](ScalaApplication/README.md)
* [IBM Streams sample application for ingesting](IngestUsingIBMStreams/README.md)
* [Java sample application](JavaApplication/README.md)
* [Python sample application](PythonApplication/README.md)
* [JDBC sample application](JDBCApplication/README.md)

## Setup your environment to run these sample applications

> Note the following assumes you are running these examples from a RedHat / CentOS environment. Use these as a guidance to complete your setup if you are running from a different environment.

### Spark Setup

To get Spark 2.0.2 on your system, follow these steps:

* Go to: https://spark.apache.org/downloads.html
* For "Choose a Spark release" entry, select "2.0.2 (Nov 2016)"
* For "Choose a package type", select:  "Pre-build for Apache 2.6 or later"  (Note you could select 2.7 as well)
* Then under "Download Spark" and click on spark-2.0.2-bin-hadoop2.6.tgz
* Wherever you stored the tired file above (e.g. under "/home/<userid>), untarnished the file using: tar -xvf spark-2.0.2-bin-hadoop2.7.tgz
* In the window you want to execute remote applications, set the SPARK_HOME using the directory where you untared (e.g., /home/<userid>) and set:
   * `export SPARK_HOME=<directory where untared>/spark-2.0.2-bin-hadoop2.6`
   * E.g., `export SPARK_HOME=/home/<userid>/spark-2.0.2-bin-hadoop2.6`

### Java Setup

To set up java (for java 1.8) use: 

* `sudo yum install java`
* `sudo yum install java-devel`

### Scala Setup

To set up scala use:

* `wget http://downloads.typesafe.com/scala/2.11.8/scala-2.11.8.rpm`
* `sudo rpm -ihv scala-2.11.8.rpm`

### SBT Setup

To set up SBT use:

* `curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo`
* `sudo yum install sbt-launcher-packaging`
* You can see the version with: `sbt sbtVersion`

### Python Setup

To setup the python environment

* Get Python 2.7.5 from steps in https://tecadmin.net/install-python-2-7-on-centos-rhel/ (where you can replace the python version with Python 2.7.5)
* Note you can use any Python version >= 2.7.5
* You will need to have pandas and numpy installed to execute the generate.sh locally so you should run the following (for Centos Linux):
   * `sudo yum install python-pip`
   * `sudo pip install numpy`
   * `sudo pip install pandas`
* Get pip3 follow: https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/
   * Install any additional required modules. For this application, you need the PySpark module:
      * `pip3 install pyspark`

### Downloading the IBM Db2 Event Store client JAR

To get the client jar go to the following and download the jar:

* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client/1.1.3

### Downloading the IBM Db2 Event Store JDBC client jar

To get the JDBC client jar go to the following and download the jar:
  
* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-jdbcdriver/1.1.3

### Downloading the IBM Db2 Event Store Python package

To get the IBM Db2 Event Store python package follow these instructions: 

* Obtain the Event Store client Python packages here and follow the README:
   * https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages
* Unzip the python.zip into your Python installation directory.
   * For `example: unzip python.zip  -d /Library/Frameworks/Python.framework/Version/2.7.5/lib/python2.7/`

* Note that to run python, you will need the following in setup_env.sh
   * `export SPARK_HOME=/home/user1/spark-2.0.2-bin-hadoop2.6`
   * `export ESLIB=<Location of the client jar>/ibm-db2-eventstore-client.jar`
   * `cp the client jar to $SPARK_HOME/jars`
   * `export PATH=$PATH:.:$SPARK_HOME/bin`
   * `export PYTHONPATH=":/usr/local/lib/python2.7/:$SPARK_HOME/python"`

