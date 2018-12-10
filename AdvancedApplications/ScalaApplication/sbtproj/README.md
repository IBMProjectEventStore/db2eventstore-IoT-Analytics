# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Scala Remote Application Execution Steps using SBT:

For an SBT project example follow these steps using the [`RemoteClientTest.scala`](RemoteClientTest.scala) application:
1. Change the IP in `ConfigurationReader.setConnectionEndpoints()` to be the IP for your IBM Db2 Event Store deployment
2. Note that in `build.sbt`, there is a library dependency from Maven for the IBM Db2 Event Store 1.1.3 client jar, namely the line: `"com.ibm.event" % "ibm-db2-eventstore-client" % "1.1.3"`
3. To run the SBT project, run the following steps:
  * `sbt clean`
  * `sbt project`
  * `sbt run`
  * Enter the DB name `TESTDB`
  * You will see that the database `TESTDB` is dropped and recreated and a new `tab1` table is created

