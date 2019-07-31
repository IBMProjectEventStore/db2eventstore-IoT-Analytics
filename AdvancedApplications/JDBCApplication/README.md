# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## Using the sample JDBC Remote Application

Follow these steps for running the JDBC java sample application ExampleJDBCApp.java:
1. First we will need to know the external IP and port to be used for JDBC connections. To do this, login to the master node 1 of the installed Db2 Event Store system and run: `kubectl get sac -n dsx`
2. Get the EXTERNAL-IP column value for the eventstore-tenant-engine-svc service, and the port number is 18729 from the exported ports (PORT(S) column) that corresponds to the JDBC port.
3. Download the SSL keystore and password through the REST API using the instructions documented in the [IBM Knowledge Center for Db2 Event Store](https://www.ibm.com/support/knowledgecenter/en/SSGNPV_2.0.0/develop/rest-api.html), this is necessary because Db2 Event Store is configured with SSL with a default keystore out of the box (this may change if you configure your own keystore after installation).
4. In ExampleJDBCApp.java, in the DriverManager.getConnection invocation, replace it to use the IP, Port, the location for the keystore, and the password, `jdbc:db2://<Your Db2 Event Store Cluster VIP>:18729/EVENTDB:sslConnection=true;sslTrustStoreLocation=<path to clientkeystore downloaded from cluster>;sslKeyStoreLocation=<path to clientkeystore downloaded from cluster>;sslKeyStorePassword=<password for clientkeystore retrieved from cluster>;sslTrustStorePassword=<password for clientkeystore retrieved from cluster>;securityMechanism=15;pluginName=IBMPrivateCloudAuth;`. Note that this is the JDBC connection URL. The database name EVENTDB is the default database that is created by Db2 Event Store at install time.
5. In runJDBCExample, change the client jar defined to ESLIB to the correct directory where ibm-db2-eventstore-client-spark-2.2.1-2.0.0.jar (which you obtained from Maven earlier from this [link](https://mvnrepository.com/artifact/com.ibm.event/ibm-db2-eventstore-client-spark-2.2.1)). this JAR includes the Db2 Standard JDBC client. Alternatively, you can download the Db2 JDBC client driver from the [IBM Data Server Client Packages page under the IBM Support website](https://www-01.ibm.com/support/docview.wss?uid=swg21385217):
6. Run the JDBC java application by running the following script from the command line: [`./runJDBCExample`](runJDBCExample)
7. It will connect to the EVENTDB database and run a simple JDBC application that creates a new table, ingests data from the CSV file, and queries the ingested data.

## Accessing IBM Db2 Event Store using Matlab

Here are the steps to get Matlab to work with Db2 Event Store:
1. Make sure you have the Database toolbox that provides the Database Explorer in Matlab
2. First go to the Matlab editor and type: edit javaclasspath.txt in the Command Window, and in that file add the file path to the Db2 JDBC client driver downloaded from the [IBM Data Server Client Packages page under the IBM Support website](https://www-01.ibm.com/support/docview.wss?uid=swg21385217):
  * E.g. `/<path where the JDBC jar was placed>/db2jcc4.jar`
3. (AFTER UPDATING javaclasspath.txt restart MATLAB or look at [this for reference](https://www.mathworks.com/matlabcentral/answers/103763-why-does-the-contents-of-javaclasspath-txt-not-get-added-to-the-static-class-path-when-i-double-clic)
4. Go to the Apps tab in Matlab app and select Database Explorer
5. Select Configure Data Source and select "Configure JDBC Data Source" from the drop down menu
6. Download the SSL keystore and password through the REST API using the instructions documented in the [IBM Knowledge Center for Db2 Event Store](https://www.ibm.com/support/knowledgecenter/en/SSGNPV_2.0.0/develop/rest-api.html), this is necessary because Db2 Event Store is configured with SSL with a default keystore out of the box (this may change if you configure it your own keystore after installation).
7. In the JDBC Data Source Configuration Editor window do the following:
  * Enter any new name for the data source, e.g. `EventStoreJDBC`
  * Enter `OTHER` as the vendor
  * For Driver enter: `com.ibm.db2.jcc.DB2Driver`
  * In URL, add in the following: `jdbc:db2://<Your Db2 Event Store Cluster VIP>:18729/EVENTDB:sslConnection=true;sslTrustStoreLocation=<path to clientkeystore downloaded from cluster>;sslKeyStoreLocation=<path to clientkeystore downloaded from cluster>;sslKeyStorePassword=<password for clientkeystore retrieved from cluster>;sslTrustStorePassword=<password for clientkeystore retrieved from cluster>;securityMechanism=15;pluginName=IBMPrivateCloudAuth;`, e.g. `jdbc:db2://9.30.192.111:18729/EVENTDB:sslConnection=true;sslTrustStoreLocation=/Users/cmgarcia/Documents/MATLAB/eventstore/clientkeystore;sslKeyStoreLocation=/Users/cmgarcia/Documents/MATLAB/eventstore/clientkeystore;sslKeyStorePassword=Cc2cZ8TxdhWf;sslTrustStorePassword=Cc2cZ8TxdhWf;securityMechanism=15;pluginName=IBMPrivateCloudAuth;`
  * Then click on any part of the window and the TEST button will pop up
  * Select TEST and you will be asked for a userid and password, where you can enter the eventstore userid and password for your system (e.g. `admin` and `password`)
  * Then you close the window. 
8. If you select and expand the default schema you will see the tables that exist in Db2 Event Store. You can expand on any of the tables and see the columns for each table. If you select the checkbox for one of the tables, a `select * from default.<tablename>` will show up in the query editor view, and if you select a subset of the columns for that table then the query will automatically only select those columns. In both cases, the query result will be displayed. If after you select a table, you can then select the Join icon at the top of the Database Explorer view, and in that view you can select another table and the join columns to view the join query and the query result.
9. Then in the Database Explore window, select the "New Query" icon which will ask for the Data Source, Username and Password. Enter the "Name" used from the JDBC window above (where it should be displayed in a drop down menu under Data Source, e.g. `EventStoreJDBC`), and enter the eventstore userid and password. Note that in this New query editor view, one can optionally use or not use the default schema name for the Event Store table(s).
