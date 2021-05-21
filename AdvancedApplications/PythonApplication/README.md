# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Python Remote Application Execution Steps:

This assumes that you have set up the environment to run a spark application. A simple option is to use the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) provided in this repository that already contains all the environment necessary to run the application. Alternatively, you can use the script used to set up spark in the docker container to set up your environment, find this in the [setup folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh).

If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). Also set up the environment variables IP with the cluster IP address, EVENT_USER with the user name, and EVENT_PASSWORD with the user password. 

For a python example [`ExamplePythonApp.py`](ExamplePythonApp.py), follow these steps:

1. To get the IBM Db2 Event Store Python client package for the 2.0 edition, get the `python.tar` from the following github repository https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages/ (not needed if using [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container))
2. cd to the directory where [`ExamplePythonApp.py`](ExamplePythonApp.py) is located
3. untar (tar -xvf python.tar) the `python.tar` file you downloaded in the current directory, so that you see an `eventstore` directory where `ExamplePythonApp.py` is located containing the Python client package (not needed if using the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container))
4. If using the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container), run this command
```
cd /root/db2eventstore-IoT-Analytics/AdvancedApplications/PythonApplication
```
6. In [`runpythonExample`](runpythonExample), you do not need to edit this line for Event Store `2.0.1.0` and `2.0.1.2`, but for other versions of Event Store you may have to edit this line to provide the correct spark jar file.
   ```
   ESLIB=/spark_home/jars/ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar
   ```
and provide the correct directory to the `ibm-db2-eventstore-client-spark-2.4.6-2.0.1.0.jar` file (which you obtained from Maven earlier from [this link](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.4.6))

5. Run the python application using: [`./runpythonExample`](runpythonExample).  If there were no tables created ignore the drop tables errors, ignore these errors
```
An error occurred while calling o0.dropTable.
: com.ibm.event.EventException: dropTable() : client request failed: DB2 SQL Error: SQLCODE=-204, SQLSTATE=42704, SQLERRMC=ADMIN.PYTHONTABLE, DRIVER=4.25.4
        at com.ibm.event.oltp.EventContext.dropTableInternal(EventContext.scala:885)
        at com.ibm.event.oltp.EventContext.dropTable(EventContext.scala:869)
        at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.lang.reflect.Method.invoke(Method.java:498)
        at py4j.reflection.MethodInvoker.invoke(MethodInvoker.java:244)
        at py4j.reflection.ReflectionEngine.invoke(ReflectionEngine.java:357)
        at py4j.Gateway.invoke(Gateway.java:282)
        at py4j.commands.AbstractCommand.invokeMethod(AbstractCommand.java:132)
        at py4j.commands.CallCommand.execute(CallCommand.java:79)
        at py4j.GatewayConnection.run(GatewayConnection.java:238)
        at java.lang.Thread.run(Thread.java:748)
```
7. The application will create the table "PYTHONTABLE", insert some rows into it and then query them to show the contents. The of the successful output will look like
```
Inserting batch rows:
{'deviceID': 1, 'sensorID': 48, 'ts': 1541019342393, 'ambient_temp': 25.983183481618322, 'power': 14.65874116573845, 'temperature': 48.908846094198}
{'deviceID': 1, 'sensorID': 24, 'ts': 1541019343497, 'ambient_temp': 22.54544424024718, 'power': 9.834894630821138, 'temperature': 39.065559149361725}
{'deviceID': 2, 'sensorID': 39, 'ts': 1541019344356, 'ambient_temp': 24.3246538655206, 'power': 14.100638100780325, 'temperature': 44.398837306747936}
{'deviceID': 2, 'sensorID': 1, 'ts': 1541019345216, 'ambient_temp': 25.658280957413456, 'power': 14.24313156331591, 'temperature': 45.29125502970843}
{'deviceID': 2, 'sensorID': 20, 'ts': 1541019346515, 'ambient_temp': 26.836546274856012, 'power': 12.841557839205619, 'temperature': 48.70012987940281}
{'deviceID': 1, 'sensorID': 24, 'ts': 1541019347200, 'ambient_temp': 24.960868340037266, 'power': 11.773728418852778, 'temperature': 42.16182979507462}
{'deviceID': 1, 'sensorID': 35, 'ts': 1541019347966, 'ambient_temp': 23.702427653296127, 'power': 7.518410399539017, 'temperature': 40.792013056811854}
{'deviceID': 1, 'sensorID': 32, 'ts': 1541019348864, 'ambient_temp': 24.041498741678787, 'power': 10.201932496584643, 'temperature': 41.66466286829134}
{'deviceID': 2, 'sensorID': 47, 'ts': 1541019349485, 'ambient_temp': 27.08539645799291, 'power': 7.8056252931945505, 'temperature': 45.60739506495865}
{'deviceID': 1, 'sensorID': 12, 'ts': 1541019349819, 'ambient_temp': 20.633590441185767, 'power': 10.344877516971517, 'temperature': 37.51407529524837}
{'deviceID': 1, 'sensorID': 4, 'ts': 1541019350783, 'ambient_temp': 23.012287834260334, 'power': 2.447688691613579, 'temperature': 34.79661868855471}
{'deviceID': 2, 'sensorID': 36, 'ts': 1541019352265, 'ambient_temp': 25.273804995718525, 'power': 14.528335246796269, 'temperature': 46.72177681202886}
{'deviceID': 1, 'sensorID': 30, 'ts': 1541019352643, 'ambient_temp': 24.553738496779705, 'power': 13.167511398437746, 'temperature': 45.717600493755896}
+--------+--------+-------------+------------------+------------------+------------------+
|DEVICEID|SENSORID|           TS|      AMBIENT_TEMP|             POWER|       TEMPERATURE|
+--------+--------+-------------+------------------+------------------+------------------+
|       1|      12|1541019349819|2.06335904411858E1|1.03448775169715E1|3.75140752952484E1|
|       1|      35|1541019347966|2.37024276532961E1|7.51841039953902E0|4.07920130568119E1|
|       2|       1|1541019345216|2.56582809574135E1|1.42431315633159E1|4.52912550297084E1|
|       2|      20|1541019346515| 2.6836546274856E1|1.28415578392056E1|4.87001298794028E1|
|       2|      47|1541019349485|2.70853964579929E1|7.80562529319455E0|4.56073950649587E1|
|       1|      48|1541019342393|2.59831834816183E1|1.46587411657384E1| 4.8908846094198E1|
|       1|      32|1541019348864|2.40414987416788E1|1.02019324965846E1|4.16646628682913E1|
|       1|      30|1541019352643|2.45537384967797E1|1.31675113984377E1|4.57176004937559E1|
|       2|      36|1541019352265|2.52738049957185E1|1.45283352467963E1|4.67217768120289E1|
|       2|      39|1541019344356|2.43246538655206E1|1.41006381007803E1|4.43988373067479E1|
|       1|      24|1541019343497|2.25454442402472E1|9.83489463082114E0|3.90655591493617E1|
|       1|      24|1541019347200|2.49608683400373E1|1.17737284188528E1|4.21618297950746E1|
|       1|       4|1541019350783|2.30122878342603E1|2.44768869161358E0|3.47966186885547E1|
+--------+--------+-------------+------------------+------------------+------------------+

```
9. Note if you look at [`runpythonExample`](runpythonExample), it's recommended to use `spark-submit` with Spark 2.0.2 since it easily processes python apps.

