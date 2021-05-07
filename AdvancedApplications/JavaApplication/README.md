# Java remote application

The simplest option is to use the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) provided in this repository which is preconfigured to run the application. 

Alternatively, you can use the script used to set up Java in the Docker container to set up your environment. The script can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh). You will also need to run the script to configure SSL that can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). You will also need to set up the environment variables
* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password 

# Running Java application
The application creates a table, inserts batches of rows and executes a select statement from the table to retrieve all the rows inserted. To run the Java example follow these steps:

1. In [runjavaExample](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/JavaApplication/runjavaExample), you may need to edit this line
```
ESLIB=${SPARK_HOME}/jars/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar
```
to reflect Spark client version (jar file) you are using.   You may need to change `ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar` if this is not spark client jar on your system. The jar file is in the `spark_home/jars` directory, the default directory used by the setup script. For example for Event Store 2.0.1.0 the client file is `ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar`. The jar file was obtained from Maven earlier [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.4.6).


2. Run the Java application by executing the following script from the command line

[`./runjavaExample`](./runjavaExample)
