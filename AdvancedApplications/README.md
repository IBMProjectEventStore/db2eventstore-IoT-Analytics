# Ingesting data using IBM Streams and running remote applications with IBM Db2 Event Store

## Introduction 

This document provides information to set up and environment in which you can run the IBM Streams application
and remote acess appplications on Event Store. You have the option of either manually setting up the run-time environment or creating a container called eventstore_demo container in which everything is pre-configured.

The following directories contain step by step instructions on ingesting data using IBM Streams and running external applications using several access methods including Python, Java, Scala, and directly using JDBC. 

Follow these links to get to specifics for each sample application:

* [Scala sample application to ingest and query](ScalaApplication/README.md)
* [IBM Streams sample application for ingesting](IngestUsingIBMStreams/README.md)
* [Java sample application](JavaApplication/README.md)
* [Python sample application](PythonApplication/README.md)
* [JDBC sample application](JDBCApplication/README.md)

## Environment setup to run sample applications

You have the option of either setting up the environment in a docker container for all applications or picking a specific appliciaton. It is assumed you are running in a RedHat / CentOS environment. If that is not true, use this material as guidance to complete your setup.

### Docker container option

Instructions to build a docker container are found [her](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container). The container is configured to run all sample applications.

### Specific applicaition option

#### Spark Setup

To install Spark 2.4.6, follow these steps:

* Go to https://archive.apache.org/dist/spark/spark-2.4.6/
* Download spark-2.4.6-bin-hadoop2.6.tgz (suggest using  "/home/<userid>)
* Where the tar file was downloaded to open the archive using
  `tar -xvf spark-2.4.6-bin-hadoop2.6.tgz`
* In the terminal session the remote application(s) will be run, set the SPARK_HOME variable using the directory where the archived was untarred (e.g., /home/<userid>).
`export SPARK_HOME=/home/<userid>/spark-2.4.6-bin-hadoop2.6`

You can also refer to the script used to set up the [container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh) if yuu would like to see the details of what was run.

#### Java Setup

To set up java (for java 1.8) use: 

`sudo yum install java`
`sudo yum install java-devel`

You can also refer to the script used to set up the [container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh) f yuu would like to see the details of what was run.

#### Scala Setup

To set up scala use:

`wget http://downloads.typesafe.com/scala/2.11.8/scala-2.11.8.rpm`
`sudo rpm -ihv scala-2.11.8.rpm`

You can also refer to the script used to set up the [container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh) f yuu would like to see the details of what was run.

#### SBT Setup

To set up SBT use:

`curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo`
`sudo yum install sbt-launcher-packaging`

To find the version use 

`sbt sbtVersion`

You can also refer to the script used to set up the [container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh) yuu would like to see the details of what was run.

#### Python Setup

To setup the Python 3.6.8 environment do the following. You will need to have pandas and numpy installed to execute the generate.sh locally(for Centos Linux) .

* Download the package from https://www.python.org/ftp/python/3.6.8
* Open the archive
`cd /<directory archived was tarred into>
`./configure --enable-optimizations`
`make altinstall`
`sudo yum install python-pip`
`sudo pip install numpy`
`sudo pip install pandas`
* Install pip3 following thes instructins: https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/
* Install the PySpark module
`pip3 install pyspark`

You can also refer to the script used to set up the [container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-python.sh) yuu would like to see the details of what was run.

#### ODBC/DB2CLI Setup

To setup the ODBC client environment

* Download version 11.5 GA of the IBM Data Server Driver Package (including the ODBC driver) or IBM Data Server Driver for ODBC and CLI from the site below, selecting your host platform. You are required to have an IBM id in order to download this package. After the file is downloaded you need to copy it to the host or the container from where you intend to run your ODBC application. 

  https://www.ibm.com/support/pages/download-initial-version-115-clients-and-drivers
  
> Note: If setting up for the [demo container], download this version **IBM Data Server Driver Package (Linux AMD64 and Intel EM64T)** (https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) and copy this within the container.

* Go the location where the IBM Data Server Driver Package was saved on your host and unpack it onto a previusly created directory `<ds_driver_path>`.

`tar -xvf ibm_data_server_driver_package_linuxx64_v11.5.tar.gz -C <ds_driver_path>`

* Find the ODBC client package `ibm_data_server_driver_for_odbc_cli.tar.gz` within `<ds_driver_path>`. For example, it might be found under `dsdriver/odbc_cli_driver/linuxamd64`. Then proceed to unpack onto a previusly created directory `<odbc_path>`. 

`tar -xvf <ds_driver_path>/odbc_cli_driver/<your platform>/ibm_data_server_driver_for_odbc_cli.tar.gz -C <odbc_path>`

* Then copy the gssplugin libraries from the `security32` or `security64` directory (depending on your architecture) within the IBM Data Server Driver Package (for example `<ds_driver_path>/security64`) to the directory where you unpacked your odbc client (`<odbc_path>`). The gssplugin libraries are used by the ODBC client to connect to Db2 Event Store. The plugin will not be picked up by the ODBC client if you move it to other directories under the ODBC client directory.

`cp -r <ds_driver_path>/security64/* <odbc_path>`

* You will need the `<odbc_path>` if you want to run [the ODBC example application](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications/ODBCApplication).

#### Downloading the IBM Db2 Event Store client JAR

To get the client jar go to the following and download the jar:

* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1

### Downloading the IBM Db2 Event Store JDBC client jar

To get the JDBC client jar go to the following and download the jar:
  
* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1

#### Downloading the IBM Db2 Event Store Python package

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

