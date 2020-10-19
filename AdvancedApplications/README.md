# Ingesting data using IBM Streams and running remote applications with IBM Db2 Event Store

## Introduction 
This document provides instructions to set up a system and run IBM Streams and remote access appplications on Event Store. You can either manually set up a run-time environment or you can create an eventstore_demo container which contains all the applications. To set up the container use these [instructions]. (https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/container) If you decide to set up just the environments you are interested in, follow the specific instructions below. 

There are is a directory for each sample application with step by step instructions to run the application.  The following links will take you to readme files describing how to run each application:

* [Scala sample application to ingest and query](ScalaApplication/README.md)
* [IBM Streams sample application for ingesting](IngestUsingIBMStreams/README.md)
* [Java sample application](JavaApplication/README.md)
* [Python sample application](PythonApplication/README.md)
* [JDBC sample application](JDBCApplication/README.md)

## Manual environment setup for sample applications

The following assumes you are in a RedHat / CentOS environment. Use these instrutions as guidance if you are setting up in a different environment.


### Spark Setup

To get Spark 2.4.6 on your system, follow these steps:

* Go to: https://archive.apache.org/dist/spark/spark-2.4.6/ to download Spark release "2.4.6"
* From that folder, download spark-2.4.6-bin-hadoop2.6.tgz that is built for Hadoop 2.6
* Go to the directory where the file was downloaded (e.g. under "/home/<userid>), open the archive using: tar -xvf spark-2.4.6-bin-hadoop2.6.tgz
* In the window you want to execute remote applications, set the SPARK_HOME using the directory where you unpacked the tar file (e.g., /home/<userid>) and set:
   * `export SPARK_HOME=<directory where untarred>/spark-2.4.6-bin-hadoop2.6`
   * E.g., `export SPARK_HOME=/home/<userid>/spark-2.4.6-bin-hadoop2.6`

Another reference source is to look at the script used in the [container setup](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh).

### Java Setup

To set up java (for java 1.8) use: 

* `sudo yum install java`
* `sudo yum install java-devel`

Another reference source is to look at the script used in the [container setup](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh).

### Scala Setup

To set up scala use:

* `wget http://downloads.typesafe.com/scala/2.11.8/scala-2.11.8.rpm`
* `sudo rpm -ihv scala-2.11.8.rpm`

Another reference source is to look at the script used in the [container setup](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh).

### SBT Setup

To set up SBT use:

* `curl https://bintray.com/sbt/rpm/rpm | sudo tee /etc/yum.repos.d/bintray-sbt-rpm.repo`
* `sudo yum install sbt-launcher-packaging`
* You can see the version with: `sbt sbtVersion`

Another reference source is to look at the script used in the [container setup](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh).

### Python Setup

To setup the Python environment

* Download and setup Python 3.6.8 
   * Download the package from https://www.python.org/ftp/python/3.6.8 and open the archive
   * Run the following to configure the downloaded package and install it 
      * ```./configure --enable-optimizations```
      * ```make altinstall```
* You will need to have pandas and numpy installed to execute the generate.sh locally so you should run the following (for Centos Linux):
   * `sudo yum install python-pip`
   * `sudo pip install numpy`
   * `sudo pip install pandas`
* Get pip3 from: https://www.liquidweb.com/kb/how-to-install-pip-on-centos-7/
   * Install any additional required modules. For this application, you need the PySpark module:
      * `pip3 install pyspark`

Another reference source is to look at the script used in the [container setup](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-python.sh).

### ODBC/DB2CLI Setup

To setup the ODBC client environment

* Download the 11.5 GA version IBM Data Server Client Package according to your host platform from
  https://www.ibm.com/support/pages/download-initial-version-115-clients-and-drivers
> Note: Download this version **IBM Data Server Driver Package (Linux AMD64 and Intel EM64T)** if setting up for the [demo container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container)
* Unpack the package at any location
   * `tar -xvf ibm_data_server_driver_package_linuxx64_v11.5.tar.gz -C <ds_driver_path>`
* Unpack the ODBC client to under the server package to any location.
   * `tar -xvf <ds_driver_path>/dsdriver/odbc_cli_driver/linuxamd64(or your own platform)/ibm_data_server_driver_for_odbc_cli.tar.gz -C <odbc_path>`
* Copy the gssplugin libraries from the IBM Data Server Driver Package to the directory where you unpacked your ODBC client.
   * `cp -r <ds_driver_path>/<security32|security64> <odbc_path>/`
   * the gssplugin libraries will be used by ODBC client to connect to Eventstore.
   * The plugin will not be picked up by the ODBC client if you move it to other directories under the ODBC client directory. 
* Remember the `odbc_path` if you later wish to run [the ODBC example APP](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications/ODBCApplication)

### Downloading the IBM Db2 Event Store client JAR

To get the client jar go to the following and download the jar:

* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1

### Downloading the IBM Db2 Event Store JDBC client jar

To get the JDBC client jar go to the following and download the jar:
  
* https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1

### Downloading the IBM Db2 Event Store Python package

To get the IBM Db2 Event Store python package follow these instructions: 

* Obtain the Event Store client Python packages here and follow the README:
   * https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages
* Unzip the python.zip into your Python installation directory.
   * For `example: unzip python.zip  -d /Library/Frameworks/Python.framework/Version/2.7.5/lib/python2.7/`

* Note that to run python, you will need the following in setup_env.sh
   * `export SPARK_HOME=/home/user1/spark-2.0.2-bin-hadoop2.6`
   * `export ESLIB=<Location of the client jar>/ibm-db2-eventstore-client.jar`
   * `cp the client jar to $SPARK_HOME/jars`
   * `export PATH=$PATH:.:$SPARK_HOME/bin`
   * `export PYTHONPATH=":/usr/local/lib/python2.7/:$SPARK_HOME/python"`
