# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Java Remote Application Execution Steps:

For a java example [`ExampleJavaApp.java`](ExampleJavaApp.java), follow these steps:
1. In [`ExampleJavaApp.java`](ExampleJavaApp.java), change the IP in `ConfigurationReader.setConnectionEndpoints()` API to be the IP for your IBM Db2 Event Store deployment
2. In `runjavaExample`, change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-1.1.3.jar` (which you obtained from Maven earlier)
3. Run the java application by running the following script from the command line: [`./runjavaExample`](./runjavaExample)
4. This application assumes the `TESTDB` database already exists, and then it creates an `Ads` table, inserts batches of rows to it and finally executes a `select * from Ads` to retrieve all the rows inserted.

