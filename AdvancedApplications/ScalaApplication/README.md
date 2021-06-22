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
cd /root/db2eventstore-IoT-Analytics/AdvancedApplications/ScalaApplication
./runscalaExample
```
If not in the docker container follow these steps: 
1. In [runscalaExample](runscalaExample), change the client jar defined with `ESLIB` to the directory where the client Spark jar file, for the Event Store `2.0.1.0` and `2.0.1.2` releases this is set to `ESLIB=${SPARK_HOME}/jars/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar`, for the prior Event Store release it was set to ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar.  The Spark jar file was obtained from Maven earlier [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.4.6) for the current release and [here](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1) for the prior release.
2. Run the Scala application by executing the following script from the command line

`./runscalaExample`

3. Ignore these 2 errors
```
cat: /usr/lib/jvm/java-1.8.0-openjdk/release: No such file or directory
```
and  this error
```
Table schema = ResolvedTableSchema(tableName=ADMINSCALATABLE, schemaName=ADMIN, tableID=0, tableGroupName=sys_ADMINSCALATABLE, tableGroupID=0, numShareds=36, schema=StructType(StructField(DEVICEID,IntegerType,false), StructField(SENSORID,IntegerType,false), StructField(TS,LongType,false), StructField(AMBIENT_TEMP,DoubleType,false), StructField(POWER,DoubleType,false), StructField(TEMPERATURE,DoubleType,false)),
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
