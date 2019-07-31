# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Python Remote Application Execution Steps:

This assumes that you have set up the environment to run a spark application. A simple option is to use the [docker container](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container) provided in this repository that already contains all the environment necessary to run the application. Alternatively, you can use the script used to set up spark in the docker container to set up your environment, find this in the [setup folder in this repository](https://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-spark.sh).

If not running within the docker container, run the script to configure SSL that is provided in the container [set up folder in this repository](ttps://github.com/IBMProjectEventStore/db2eventstore-IoT-Analytics/blob/master/container/setup/setup-ssl.sh). Also set up the environment variables IP with the cluster IP address, EVENT_USER with the user name, and EVENT_PASSWORD with the user password. 

For a python example [`ExamplePythonApp.py`](ExamplePythonApp.py), follow these steps:

1. To get the IBM Db2 Event Store Python client package for the 2.0 edition, get the `python.zip` from the following github repository https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages/
2. cd to the directory where [`ExamplePythonApp.py`](ExamplePythonApp.py) is located
3. unzip the `python.zip` file you downloaded in the current directory, so that you see an `eventstore` directory where `ExamplePythonApp.py` is located containing the Python client package
4. In [`runpythonExample`](runpythonExample), change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar` (which you obtained from Maven earlier from [this link](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1))
5. Run the python application using: [`./runpythonExample`](runpythonExample)
6. The application will create the table "PYTHONTABLE", insert some rows into it and then query them to show the contents.
7. Note if you look at [`runpythonExample`](runpythonExample), it's recommended to use `spark-submit` with Spark 2.0.2 since it easily processes python apps.

