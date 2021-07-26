# Java remote application

The simplest option is to use the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) provided in this repository which is preconfigured to run the application. 

Alternatively, you can use the script used to set up Java in the Docker container to set up your environment. The script can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-java.sh). You will also need to run the script to configure SSL that can be found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). You will also need to set up the environment variables
* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password 

# Running Java application
The application creates a table, inserts batches of rows and executes a select statement from the table to retrieve all the rows inserted. To run the Java example follow these steps:

1. If using the docker container, inside the container run these commands to run the Java application
```
cd /root/db2eventstore-IoT-Analytics/AdvancedApplications/JavaApplication
./runjavaExample
```
2 . The end of successful output will look something like
```
21/05/21 22:57:18 INFO DAGScheduler: Job 0 finished: show at ExampleJavaApp.java:192, took 2.413213 s
+--------+--------+-------------+------------------+------------------+------------------+
|DEVICEID|SENSORID|           TS|      AMBIENT_TEMP|             POWER|       TEMPERATURE|
+--------+--------+-------------+------------------+------------------+------------------+
|       2|      20|1541019346515| 2.6836546274856E1|1.28415578392056E1|4.87001298794028E1|
|       1|      48|1541019342393|2.59831834816183E1|1.46587411657384E1| 4.8908846094198E1|
|       2|      39|1541019344356|2.43246538655206E1|1.41006381007803E1|4.43988373067479E1|
|       1|      24|1541019343497|2.25454442402472E1|9.83489463082114E0|3.90655591493617E1|
|       2|       1|1541019345216|2.56582809574135E1|1.42431315633159E1|4.52912550297084E1|
+--------+--------+-------------+------------------+------------------+------------------+

done.
21/05/21 22:57:18 INFO SparkContext: Invoking stop() from shutdown hook
21/05/21 22:57:18 INFO SparkUI: Stopped Spark web UI at http://localhost:4040
21/05/21 22:57:18 INFO MapOutputTrackerMasterEndpoint: MapOutputTrackerMasterEndpoint stopped!
21/05/21 22:57:18 INFO MemoryStore: MemoryStore cleared
21/05/21 22:57:18 INFO BlockManager: BlockManager stopped
21/05/21 22:57:19 INFO BlockManagerMaster: BlockManagerMaster stopped
21/05/21 22:57:19 INFO OutputCommitCoordinator$OutputCommitCoordinatorEndpoint: OutputCommitCoordinator stopped!
21/05/21 22:57:19 INFO SparkContext: Successfully stopped SparkContext
21/05/21 22:57:19 INFO ShutdownHookManager: Shutdown hook called
21/05/21 22:57:19 INFO ShutdownHookManager: Deleting directory /tmp/spark-85c2903b-7043-48a4-862e-0b0dcd73d055
21/05/21 22:57:19 INFO ShutdownHookManager: Deleting directory /tmp/spark-66f8c036-bbd0-48a9-afcd-931db91c4fa6
```

In [runjavaExample](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/AdvancedApplications/JavaApplication/runjavaExample), for the Event Store `2.0.1.0` or `2.0.1.2` you do not have to edit the line below, but for other releases of Event Store you may need to edit this line
```
ESLIB=${SPARK_HOME}/jars/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar
```
to reflect Spark client version (jar file) you are using.   You may need to change `ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar` if this is not spark client jar on your system. The jar file is in the `spark_home/jars` directory, the default directory used by the setup script. For example for Event Store 2.0.1.0 the client file is `ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar`. The jar file was obtained from Maven earlier [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.4.6).

## Troubleshooting
If you see this error
```
[root@d2b8991602f7 ~]# cd /root/db2eventstore-IoT-Analytics/AdvancedApplications/JavaApplication
[root@d2b8991602f7 JavaApplication]# ./runjavaExample
Compile java code
Make a jar with java class
execute with spark submit
21/06/30 22:41:50 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Unable to load conf/log4j-defaults.properties
log4j:WARN No appenders could be found for logger (com.ibm.event.common.ConfigurationReader).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
Connect to database EVENTDB
SQLException information
Error msg: [jcc][t4][2030][11211][4.25.4] A communication error occurred during operations on the connection's underlying socket, socket input stream, 
or socket output stream.  Error location: Reply.fill() - socketInputStream.read (-1).  Message: Remote host terminated the handshake. ERRORCODE=-4499, SQLSTATE=08001
SQLSTATE: 08001
Error code: -4499
com.ibm.db2.jcc.am.DisconnectNonTransientConnectionException: [jcc][t4][2030][11211][4.25.4] A communication error occurred during operations on the connection's underlying socket, socket input stream, 
or socket output stream.  Error location: Reply.fill() - socketInputStream.read (-1).  Message: Remote host terminated the handshake. ERRORCODE=-4499, SQLSTATE=08001
	at com.ibm.db2.jcc.am.b6.a(b6.java:338)
	at com.ibm.db2.jcc.t4.a.a(a.java:572)
  ```
  You most likely need to update eiher or both the backend db2 and eventstore ports in `/etc/haproxy/haproxy.cfg` on your OpenShift infrastructure node (IBM fyre uses an infrastructure node as a means to proxy traffic to and from the OpenShift cluster).  See here for [instructions to fix this](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/tree/master/AdvancedApplications/ScalaApplication#troubleshooting)
