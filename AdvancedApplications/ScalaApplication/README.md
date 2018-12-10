# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Scala Remote Application Execution Steps:

To run a scala example with SBT, cd to the [`sbtproj`](sbtproj/README.md) directory which contains the [`RemoteClientTest.scala`](sbtproj/RemoteClientTest.scala) application

For a scala example `ExampleScalaApp.scala`, follow these steps:

1. In [`ExampleScalaApp.scala`](ExampleScalaApp.scala), change the IP in `ConfigurationReader.setConnectionEndpoints()` to be the IP for your IBM Db2 Event Store deployment
2. In [`runscalaExample`](runscalaExample), change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-1.1.3.jar` (which you obtained from Maven earlier)
3. Run the scala application by running the following script from the command line: `./runscalaExample`
4. Enter the DB name: `TESTDB`
5. Enter the table name: `tab1`
6. This will make the `tab1` table and insert a single row to it and also create the `IOT_TEMP` table that is used to store the rows to be inserted in the [IBM Streams application](../IngestUsingIBMStreams/README.md)

