# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Python Remote Application Execution Steps:

For a python example [`ExamplePythonApp.py`](ExamplePythonApp.py), follow these steps:

> Note that this requires the table created using the [`ExampleScalaApp.scala`](../ScalaApplication/ExampleScalaApp.scala) application

1. To get the IBM Db2 Event Store Python client package for the 1.1.3 edition, get the `python.zip` from the following github repository https://github.com/IBMProjectEventStore/db2eventstore-pythonpackages/
2. cd to the directory where [`ExamplePythonApp.py`](ExamplePythonApp.py) is located
3. unzip the `python.zip` file you downloaded in the current directory, so that you see an `eventstore` directory where `ExamplePythonApp.py` is located containing the Python client package
4. In [`ExamplePythonApp.py`](ExamplePythonApp.py), change the IP in `ConfigurationReader.setConnectionEndpoints()` to be the IP for your IBM Db2 Event Store deployment
5. In [`runpythonExample`](runpythonExample), change the client jar defined to `ESLIB` to the correct directory where `ibm-db2-eventstore-client-1.1.3.jar` is located (which you obtained from Maven earlier)
6. Run the python application using: [`./runpythonExample`](runpythonExample)
7. Note that this will just query table "tab1" to show the count and the contents where that table was the one made in the [`ExampleScalaApp.scala`](../ScalaApplication/ExampleScalaApp.scala) run before
8. Note if you look at [`runpythonExample`](runpythonExample), it's recommended to use `spark-submit` with Spark 2.0.2 since it easily processes python apps.

