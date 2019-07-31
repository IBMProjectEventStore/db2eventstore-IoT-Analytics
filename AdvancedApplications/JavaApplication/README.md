# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Java Remote Application Execution Steps:

This assumes that you have set up the environment to run a java application. A simple option is to use the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) provided in this repository that already contains all the environment necessary to run the application. Alternatively, you can use the script used to set up java in the docker container to set up your environment, find this in the [setup folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh).

If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). Also set up the environment variables IP with the cluster IP address, EVENT_USER with the user name, and EVENT_PASSWORD with the user password. 

For a java example [`ExampleJavaApp.java`](ExampleJavaApp.java), follow these steps:
1. In `runjavaExample`, change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar` (which you obtained from Maven earlier from [this link](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1))
2. Run the java application by running the following script from the command line: [`./runjavaExample`](./runjavaExample)
3. The application creates the table, inserts batches of rows to it and finally executes a `select * from <table>` to retrieve all the rows inserted.
