from eventstore.oltp import EventContext
from pyspark.sql import SparkSession
from eventstore.sql import EventSession
from eventstore.common import ConfigurationReader
from eventstore.catalog import TableSchema, IndexSpecification, SortSpecification, ColumnOrder
from pyspark.sql.types import *

import os

# set connection endpoint
ip = os.environ['IP'];
print("Connecting to {}".format(ip))
ConfigurationReader.setConnectionEndpoints("{}:18730;{}:1101".format(ip,ip))
ConfigurationReader.setConnectionTimeout(2)

# set user credential
ConfigurationReader.setEventUser(os.environ['EVENT_USER']);
ConfigurationReader.setEventPassword(os.environ['EVENT_PASSWORD']);

# set SSL credentials
ConfigurationReader.setSslTrustStoreLocation(os.environ['KEYDB_PATH']);
ConfigurationReader.setSslTrustStorePassword(os.environ['KEYDB_PASSWORD']);
ConfigurationReader.setSslKeyStoreLocation(os.environ['KEYDB_PATH']);
ConfigurationReader.setSslKeyStorePassword(os.environ['KEYDB_PASSWORD']);
ConfigurationReader.setClientPlugin(True);
ConfigurationReader.setClientPluginName("IBMIAMauth");
ConfigurationReader.setSSLEnabled(True);

# connect to db2
sparkSession = SparkSession.builder.appName("EventStore in Python").getOrCreate()
dbName="EVENTDB";
print("Opening database {}".format(dbName))
eventSession = EventSession(sparkSession.sparkContext, dbName)
eventSession.open_database()

# create table and ingest
tabName = "PYTHONTABLE" 
with EventContext.get_event_context(dbName) as ctx:
   # creating table schema
   tableSchema = TableSchema(tabName, StructType([
       StructField("deviceID", IntegerType(), nullable = False),
       StructField("sensorID", IntegerType(), nullable = False),
       StructField("ts", LongType(), nullable = False),
       StructField("ambient_temp", DoubleType(), nullable = False),
       StructField("power", DoubleType(), nullable = False),
       StructField("temperature", DoubleType(), nullable = False)
       ]),
       sharding_columns = ["deviceID", "sensorID"],
       pk_columns = ["deviceID", "sensorID", "ts"]
   )

   # creating table index specification
   indexSpec = IndexSpecification(
       index_name=tabName + "Index",
       table_schema=tableSchema,
       equal_columns = ["deviceID", "sensorID"],
       sort_columns = [SortSpecification("ts", ColumnOrder.DESCENDING_NULLS_LAST)],
       include_columns = ["temperature"]
    )

   # drop old table if exists
   print("Dropping table {}".format(tabName))
   try:
      ctx.drop_table(tabName)
   except Exception as e:
      print (e);
      assert str(e).find("SQLCODE=-204")!=-1
      print("Table not found, skip dropping table")

   # create new table
   print("creating table with index...\n{}".format(tableSchema))
   ctx.create_table_with_index(tableSchema, indexSpec)
   print("Table {} is created successfully".format(tabName))

   # print all tables in database
   allTables = ctx.get_names_of_tables()
   for idx, name in enumerate(allTables):
      print(name)

   # ingest into table
   table = ctx.get_table(tabName)
   print("Table schema = {}".format(table))
   row_batch=[]
   column=["deviceID","sensorID","ts","ambient_temp","power","temperature"]
   rows=[[1,48,1541019342393,25.983183481618322,14.65874116573845,48.908846094198],
         [1,24,1541019343497,22.54544424024718,9.834894630821138,39.065559149361725],
         [2,39,1541019344356,24.3246538655206,14.100638100780325,44.398837306747936],
         [2,1,1541019345216,25.658280957413456,14.24313156331591,45.29125502970843],
         [2,20,1541019346515,26.836546274856012,12.841557839205619,48.70012987940281],
         [1,24,1541019347200,24.960868340037266,11.773728418852778,42.16182979507462],
         [1,35,1541019347966,23.702427653296127,7.518410399539017,40.792013056811854],
         [1,32,1541019348864,24.041498741678787,10.201932496584643,41.66466286829134],
         [2,47,1541019349485,27.08539645799291,7.8056252931945505,45.60739506495865],
         [1,12,1541019349819,20.633590441185767,10.344877516971517,37.51407529524837],
         [1,4,1541019350783,23.012287834260334,2.447688691613579,34.79661868855471],
         [2,36,1541019352265,25.273804995718525,14.528335246796269,46.72177681202886],
         [1,30,1541019352643,24.553738496779705,13.167511398437746,45.717600493755896]]
   print("Inserting batch rows:")
   for row in rows:
      row_batch.append(dict(zip(column,row)));
      print (row_batch[-1])
   ctx.batch_insert(table, row_batch)
   
# load data from table
eventSession.set_query_read_option("SnapshotNone") 
table = eventSession.load_event_table(tabName)
table.createOrReplaceTempView(tabName)
result = eventSession.sql("SELECT * FROM {}".format(tabName));
result.show()
