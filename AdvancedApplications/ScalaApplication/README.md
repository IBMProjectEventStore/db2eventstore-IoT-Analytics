# Scala remote application setup

The simplest option is to use the Docker container provided in this repository that is configured to run the application. 

Alternatively, you can use the script used to set up Scala in the Docker container to set up your environment. The script can be found in the setup folder [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh).  Run the script to configure SSL that found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). You will also need to set up these environment variables: 

* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password

To run a Scala example with SBT, cd to the [`sbtproj`](sbtproj/README.md) directory which contains the [`RemoteClientTest.scala`](sbtproj/RemoteClientTest.scala) application

## Running Scala example

The application will create a table, insert a small number of rows and query the inserted rows. To run the Scala example, follow these steps:

1. In [runscalaExample](runscalaExample), change the client jar defined with `ESLIB` to the directory where the client Spark jar file, for example ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar, is located. The Spark jar file was obtained from Maven earlier [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1).
2. Run the Scala application by executing the following script from the command line

`./runscalaExample`
