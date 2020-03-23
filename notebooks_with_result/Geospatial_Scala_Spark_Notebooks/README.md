### Overview:

The notebooks in this directory demonstrate the data preparation, data ingestion, and geo-spatial querying using the IBM Db2 Event Store database, as well as the advanced Spark SQL libraries built in with it.



#### Runtime Environment:

- The example notebooks are produced in IBM Cloud Paks for Data (version >= V2.5.0.0) with following add-ons:
   - IBM Db2 EventStore (Version >= v2.0.0.3)
   - IBM Watson Studio Local
   - IBM Hummingbird Spark service

#### Content:

- PySpark_Prepare_Data_from_S3.ipynb

   The notebook illustrates a data fetching and preparation process using AWS S3 storage bucket

   The real-time generated data stream are fetched from AWS S3 to be prepared, and to be later analyzed with IBM Db2 Event Store.

- Scala_Spark_Insert_and_Query_Table

   The notebook illustrates a data analysis procedure including table creation, data ingestion, and geo spatial querying using IBM Db2 Event Store’s powerful built-in Spark Geo-spatial library.

- Scala_Spark_Insert_and_Query_Table_Performance

   The notebook illustrates a data analysis procedure including table creation, data ingestion, and geo spatial querying using IBM Db2 Event Store’s powerful built-in Spark Geo-spatial library.

   Additionally, the query performance is illustrated on a complex Spark SQL query.

