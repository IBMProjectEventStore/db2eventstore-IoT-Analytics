#ExamplePythonApp

from pyspark.sql import SparkSession
from eventstore.sql import EventSession
from eventstore.common import ConfigurationReader

ConfigurationReader.setConnectionEndpoints("9.30.189.50:1101")

sparkSession = SparkSession.builder.appName("EventStore in Python").getOrCreate()

eventSession = EventSession(sparkSession.sparkContext, "TESTDB") 
eventSession.open_database()
table = eventSession.load_event_table("tab1") 
table.createOrReplaceTempView("tab1")
query = "SELECT count(*) FROM tab1" 
result = eventSession.sql(query)
result.show(50)
querycnt = "SELECT * FROM tab1" 
resultcnt = eventSession.sql(querycnt)
resultcnt.show(50)
