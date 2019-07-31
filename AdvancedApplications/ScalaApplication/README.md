# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Scala Remote Application Execution Steps:

This assumes that you have set up the environment to run a scala application. A simple option is to use the docker container provided in this repository that already contains all the environment necessary to run the application. Alternatively, you can use the script used to set up scala in the docker container to set up your environment, find this in the [setup folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh).

If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). Also set up the environment variables IP with the cluster IP address, EVENT_USER with the user name, and EVENT_PASSWORD with the user password. 

To run a scala example with SBT, cd to the [`sbtproj`](sbtproj/README.md) directory which contains the [`RemoteClientTest.scala`](sbtproj/RemoteClientTest.scala) application

For a scala example `ExampleScalaApp.scala`, follow these steps:

1. If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](ttps://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh)
2. In [`runscalaExample`](runscalaExample), change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar` (which you obtained from Maven earlier from [this link](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1))
3. Run the scala application by running the following script from the command line: `./runscalaExample`
4. This will create a new table, insert rows to it and query the inserted rows.

