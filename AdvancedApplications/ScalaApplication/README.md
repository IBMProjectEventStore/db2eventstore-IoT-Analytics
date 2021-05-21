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

3. Ignore this error
```
Table schema = ResolvedTableSchema(tableName=ADMINSCALATABLE, schemaName=ADMIN, tableID=0, tableGroupName=sys_ADMINSCALATABLE, tableGroupID=0, numShareds=36, schema=StructType(StructField(DEVICEID,IntegerType,false), StructField(SENSORID,IntegerType,false), StructField(TS,LongType,false), StructField(AMBIENT_TEMP,DoubleType,false), StructField(POWER,DoubleType,false), StructField(TEMPERATURE,DoubleType,false)),
```
As it is most likely because there are not tables to drop
