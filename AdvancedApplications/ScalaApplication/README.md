# Scala remote application setup

The simplest option is to use the Docker container provided in this repository that is configured to run the application. 

Alternatively, you can use the script used to set up Scala in the Docker container to set up your environment. The script can be found in the setup folder [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-scala.sh).  Run the script to configure SSL that found [here](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). You will also need to set up these environment variables: 

* IP with the cluster IP address
* EVENT_USER with the user name
* EVENT_PASSWORD with the user password

To run a Scala example with SBT, cd to the [`sbtproj`](sbtproj/README.md) directory which contains the [`RemoteClientTest.scala`](sbtproj/RemoteClientTest.scala) application

## Running Scala example

The application will create a table, insert a small number of rows and query the inserted rows. To run the Scala example within the docker container, run these two commands
```
cd ~/db2eventstore-IoT-Analytics/AdvancedApplications/ScalaApplication
./runscalaExample
```
If not in the docker container follow these steps: 
1. In [runscalaExample](runscalaExample), change the client jar defined with `ESLIB` to the directory where the client Spark jar file, for the Event Store `2.0.1.0`, `2.0.1.2`, `2.0.1.3` and `2.0.1.4` releases this is set to `ESLIB=${SPARK_HOME}/jars/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar`, for the prior Event Store release it was set to ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar.  The Spark jar file was obtained from Maven earlier [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.4.6) for the current release and [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1) for the prior release.
2. Run the Scala application by executing the following script from the command line

`./runscalaExample`

3. Ignore these 4 warnings (your IP address will be different)

```
21/09/02 02:55:51 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Connecting to 9.46.196.49;
Using database EVENTDB
Unable to load conf/log4j-defaults.properties
log4j:WARN No appenders could be found for logger (com.ibm.event.common.ConfigurationReader).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.


```
As it is most likely because there are not tables to drop


End of successful output is below
```
21/06/22 14:52:36 INFO DAGScheduler: failed: Set()
21/06/22 14:52:36 INFO DAGScheduler: Submitting ResultStage 1 (MapPartitionsRDD[5] at show at ExampleScalaApp.scala:115), which has no missing parents
21/06/22 14:52:36 INFO MemoryStore: Block broadcast_1 stored as values in memory (estimated size 7.0 KB, free 366.3 MB)
21/06/22 14:52:36 INFO MemoryStore: Block broadcast_1_piece0 stored as bytes in memory (estimated size 3.6 KB, free 366.3 MB)
21/06/22 14:52:36 INFO BlockManagerInfo: Added broadcast_1_piece0 in memory on localhost:37391 (size: 3.6 KB, free: 366.3 MB)
21/06/22 14:52:36 INFO SparkContext: Created broadcast 1 from broadcast at DAGScheduler.scala:1184
21/06/22 14:52:36 INFO DAGScheduler: Submitting 1 missing tasks from ResultStage 1 (MapPartitionsRDD[5] at show at ExampleScalaApp.scala:115) (first 15 tasks are for partitions Vector(0))
21/06/22 14:52:36 INFO TaskSchedulerImpl: Adding task set 1.0 with 1 tasks
21/06/22 14:52:36 INFO TaskSetManager: Starting task 0.0 in stage 1.0 (TID 1, localhost, executor driver, partition 0, NODE_LOCAL, 7767 bytes)
21/06/22 14:52:36 INFO Executor: Running task 0.0 in stage 1.0 (TID 1)
21/06/22 14:52:36 INFO ShuffleBlockFetcherIterator: Getting 1 non-empty blocks including 1 local blocks and 0 remote blocks
21/06/22 14:52:36 INFO ShuffleBlockFetcherIterator: Started 0 remote fetches in 11 ms
21/06/22 14:52:36 INFO Executor: Finished task 0.0 in stage 1.0 (TID 1). 2138 bytes result sent to driver
21/06/22 14:52:36 INFO TaskSetManager: Finished task 0.0 in stage 1.0 (TID 1) in 69 ms on localhost (executor driver) (1/1)
21/06/22 14:52:36 INFO TaskSchedulerImpl: Removed TaskSet 1.0, whose tasks have all completed, from pool
21/06/22 14:52:36 INFO DAGScheduler: ResultStage 1 (show at ExampleScalaApp.scala:115) finished in 0.085 s
21/06/22 14:52:36 INFO DAGScheduler: Job 0 finished: show at ExampleScalaApp.scala:115, took 2.236165 s
+--------+--------+-------------+------------------+------------------+------------------+
|DEVICEID|SENSORID|           TS|      AMBIENT_TEMP|             POWER|       TEMPERATURE|
+--------+--------+-------------+------------------+------------------+------------------+
|       2|       1|1541019345216|2.56582809574135E1|1.42431315633159E1|4.52912550297084E1|
|       2|      39|1541019344356|2.43246538655206E1|1.41006381007803E1|4.43988373067479E1|
|       1|      24|1541019343497|2.25454442402472E1|9.83489463082114E0|3.90655591493617E1|
|       1|      24|1541019347200|2.49608683400373E1|1.17737284188528E1|4.21618297950746E1|
|       2|      20|1541019346515| 2.6836546274856E1|1.28415578392056E1|4.87001298794028E1|
|       1|      48|1541019342393|2.59831834816183E1|1.46587411657384E1| 4.8908846094198E1|
+--------+--------+-------------+------------------+------------------+------------------+

21/06/22 14:52:36 INFO SparkContext: Invoking stop() from shutdown hook
21/06/22 14:52:36 INFO SparkUI: Stopped Spark web UI at http://localhost:4040
21/06/22 14:52:36 INFO MapOutputTrackerMasterEndpoint: MapOutputTrackerMasterEndpoint stopped!
21/06/22 14:52:36 INFO MemoryStore: MemoryStore cleared
21/06/22 14:52:36 INFO BlockManager: BlockManager stopped
21/06/22 14:52:36 INFO BlockManagerMaster: BlockManagerMaster stopped
21/06/22 14:52:36 INFO OutputCommitCoordinator$OutputCommitCoordinatorEndpoint: OutputCommitCoordinator stopped!
21/06/22 14:52:36 INFO SparkContext: Successfully stopped SparkContext
21/06/22 14:52:36 INFO ShutdownHookManager: Shutdown hook called
21/06/22 14:52:36 INFO ShutdownHookManager: Deleting directory /tmp/spark-92ed0c7c-84ad-42ce-b83f-539f311b77ac
21/06/22 14:52:36 INFO ShutdownHookManager: Deleting directory /tmp/spark-f82adf97-e732-488d-a6b6-8d3b02a7d4a7
[root@d7c734a4e19f ScalaApplication]#

```
## Troubleshooting
### Communication Error
If you get this error
```
[root@d2b8991602f7 ScalaApplication]# ./runscalaExample
Compile java code
Compile the scala application
cat: /usr/lib/jvm/java-1.8.0-openjdk/release: No such file or directory
Execute with spark submit
21/06/30 22:42:33 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Connecting to 9.30.138.71;
Using database EVENTDB
SQLException information
log4j:WARN No appenders could be found for logger (com.ibm.event.api.EventJDBCClient).
log4j:WARN Please initialize the log4j system properly.
log4j:WARN See http://logging.apache.org/log4j/1.2/faq.html#noconfig for more info.
Error msg: [jcc][t4][2030][11211][4.25.4] A communication error occurred during operations on the connection's underlying socket, socket input stream, 
or socket output stream.  Error location: Reply.fill() - socketInputStream.read (-1).  Message: Remote host terminated the handshake. ERRORCODE=-4499, SQLSTATE=08001
SQLSTATE: 08001
Error code: -4499
com.ibm.db2.jcc.am.DisconnectNonTransientConnectionException: [jcc][t4][2030][11211][4.25.4] A communication error occurred during operations on the connection's underlying socket, socket input stream, 
or socket output stream.  Error location: Reply.fill() - socketInputStream.read (-1).  Message: Remote host terminated the handshake. ERRORCODE=-4499, SQLSTATE=08001
	at com.ibm.db2.jcc.am.b6.a(b6.java:338)
	at com.ibm.db2.jcc.t4.a.a(a.java:572)
```
It most likely means the eventstore database or environment was recreated and the db2 and event store ports at the bottom of
```
/etc/haproxy/haproxy.cfg
```
are incorrect.


    Find Corresponding Node Ports of Eventstore Engine Service From the infrastructure node and as root from a terminal session run the following command, copy and paste

DB2_EXTERNAL_ENGINE_SVC=`oc get svc | grep db2eventstore-.*engine-db2-external-svc | awk '{ print $1 }'`
ES_EXTERNAL_ENGINE_SVC=`oc get svc | grep db2eventstore-.*engine-es-external-svc | awk '{ print $1 }'`
DB2_PORT=`oc get svc ${DB2_EXTERNAL_ENGINE_SVC} -o jsonpath='{.spec.ports[?(@.name=="server")].nodePort}'`
EVENTSTORE_PORT=`oc get svc ${ES_EXTERNAL_ENGINE_SVC} -o jsonpath='{.spec.ports[?(@.name=="legacy-server")].nodePort}'`
pwd

validate by running the following commands
```
echo $DB2_EXTERNAL_ENGINE_SVC
echo $ES_EXTERNAL_ENGINE_SVC=
echo $DB2_PORT
echo $EVENTSTORE_PORT
pwd
```
The values for
```
echo $DB2_PORT
echo $EVENTSTORE_PORT
```
Need to get entered as the backend db2 and backend eventstore ports
So in this example here is the ouput of those 2 commands
```
root@stroud-eventstore-2-inf ~]# echo $DB2_PORT
30614
[root@stroud-eventstore-2-inf ~]# echo $EVENTSTORE_PORT
30374
```

Now edit 
```
/etc/haproxy/haproxy.cfg
```

Change From
```
#---------------------------------------------------------------------

frontend db2
        bind *:9177
        default_backend db2
        mode tcp
        option tcplog

backend db2
        balance source
        mode tcp
        server master0 10.17.47.85:31682 check
        server master1 10.17.54.178:31682 check
        server master2 10.17.55.86:31682 check

frontend eventstore
        bind *:9178
        default_backend eventstore
        mode tcp
        option tcplog

backend eventstore
        balance source
        mode tcp
        server master0 10.17.47.85:32018 check
        server master1 10.17.54.178:32018 check
        server master2 10.17.55.86:32018 check
```
to:

```
#---------------------------------------------------------------------

frontend db2
        bind *:9177
        default_backend db2
        mode tcp
        option tcplog

backend db2
        balance source
        mode tcp
        server master0 10.17.47.85:30614 check
        server master1 10.17.54.178:30614 check
        server master2 10.17.55.86:30614 check

frontend eventstore
        bind *:9178
        default_backend eventstore
        mode tcp
        option tcplog

backend eventstore
        balance source
        mode tcp
        server master0 10.17.47.85:30374 check
        server master1 10.17.54.178:30374 check
        server master2 10.17.55.86:30374 check
```  

then restart haproxy
```
systemctl daemon-reload && systemctl restart haproxy
```
### Path Error
if you get this error
```
[root@6d2b717eb619 ScalaApplication]# ./runscalaExample
Compile java code
Compile the scala application
ExampleScalaApp.scala:6: error: object Row is not a member of package org.apache.spark.sql
import org.apache.spark.sql.Row
       ^
ExampleScalaApp.scala:7: error: object SparkConf is not a member of package org.apache.spark
import org.apache.spark.{SparkConf, SparkContext}
       ^
ExampleScalaApp.scala:43: error: Symbol 'type org.apache.spark.sql.types.StructType' is missing from the classpath.
This symbol is required by 'value com.ibm.event.catalog.TableSchema.schema'.
Make sure that type StructType is in your classpath and check for conflicting dependencies with `-Ylog-classpath`.
A full rebuild may help if 'TableSchema.class' was compiled against an incompatible version of org.apache.spark.sql.types.
    val tabSchema = TableSchema(tabName, StructType(Array(
                    ^
ExampleScalaApp.scala:88: error: not found: value Row
    val batch = IndexedSeq(Row(1,48,1541019342393L,25.983183481618322,14.65874116573845,48.908846094198),
                           ^
ExampleScalaApp.scala:89: error: not found: value Row
                    Row(1,24,1541019343497L,22.54544424024718,9.834894630821138,39.065559149361725),
                    ^
ExampleScalaApp.scala:90: error: not found: value Row
                    Row(2,39,1541019344356L,24.3246538655206,14.100638100780325,44.398837306747936),
                    ^
ExampleScalaApp.scala:91: error: not found: value Row
                    Row(2,1,1541019345216L,25.658280957413456,14.24313156331591,45.29125502970843),
                    ^
ExampleScalaApp.scala:92: error: not found: value Row
                    Row(2,20,1541019346515L,26.836546274856012,12.841557839205619,48.70012987940281),
                    ^
ExampleScalaApp.scala:93: error: not found: value Row
                    Row(1,24,1541019347200L,24.960868340037266,11.773728418852778,42.16182979507462))
                    ^
ExampleScalaApp.scala:105: error: not found: type SparkContext
    val sc = new SparkContext(new SparkConf().setAppName("ExampleScalaApp").setMaster(
                 ^
ExampleScalaApp.scala:105: error: not found: type SparkConf
    val sc = new SparkContext(new SparkConf().setAppName("ExampleScalaApp").setMaster(
                                  ^
ExampleScalaApp.scala:108: error: Symbol 'type org.apache.spark.sql.SparkSession' is missing from the classpath.
This symbol is required by 'class org.apache.spark.sql.ibm.event.EventSparkSession'.
Make sure that type SparkSession is in your classpath and check for conflicting dependencies with `-Ylog-classpath`.
A full rebuild may help if 'EventSparkSession.class' was compiled against an incompatible version of org.apache.spark.sql.
      val sqlContext = new EventSession(sc, dbName)
                           ^
ExampleScalaApp.scala:111: error: Symbol 'term org.apache.spark.sql.package' is missing from the classpath.
This symbol is required by 'method org.apache.spark.sql.ibm.event.EventSession.loadEventTable'.
Make sure that term package is in your classpath and check for conflicting dependencies with `-Ylog-classpath`.
A full rebuild may help if 'EventSession.class' was compiled against an incompatible version of org.apache.spark.sql.
      val ads = sqlContext.loadEventTable(tabName)
                ^
ExampleScalaApp.scala:114: error: value sql is not a member of org.apache.spark.sql.ibm.event.EventSession
      val results = sqlContext.sql(s"SELECT * FROM $tabName")
                               ^
14 errors found
Execute with spark submit
./runscalaExample: line 14: /spark_home/bin/spark-submit: No such file or directory
```
I was never able to figure out how to resolve.  It occurred on CentOS 8 Stream fresh install and upgrade from CentOS 8.5, Rocky Linux upgrade from CentOS 8.5, and Red Hat 7.9.  It did not occur on a Red Hat 8.5 install though
