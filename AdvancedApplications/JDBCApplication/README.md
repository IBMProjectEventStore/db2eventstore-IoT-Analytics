# Instructions on How to Run the IBM Streams and Remote Applications For IBM Db2 Event Store

## JDBC Remote Application Steps: 

For a JDBC java example ExampleJDBCApp.java, follow these steps:
1. First we will need to know the external IP to be used for JDBC connections. To do this, login to the master node 1 of the installed Event Store system and run: `kubectl get sac -n dsx`
2. Get the EXTERNAL-IP column value for the eventstore-thrift-svc service.
3. In ExampleJDBCApp.java, replace the IP in the DriverManager.getConnection to use the IP you just found for the thrift service: e.g., `jdbc:hive2://<put your IP here>:12015/TESTDB`. Note that this is the JDBC connection URL. The port listed in the get sac command above should be 12015.
4. In runJDBCExample, change the client jar defined to ESLIB to the correct directory where ibm-db2-eventstore-jdbcdriver-1.1.3.jar (which you obtained from Maven earlier)
5. Run the JDBC java application by running the following script from the command line: [`./runJDBCExample`](runJDBCExample)
6. It will connect to the TESTDB database you created earlier and run some JDBC metaData functions to show tables and columns in the database and run some queries on table "tab1"

## Accessing Event Store in DataVirtualization (QueryPlex)

DataVirtualization includes the Hive drivers and all you need to do is select Event Store as the type in the UI, enter the appropriate credentials, ip, port, etc. and the connection will work.

## Accessing Event Store using Matlab:

Here are the steps to get Matlab to work with EventStore:
1. Make sure you have the Database toolbox that provides the Database Explorer in Matlab
2. First go to the Matlab editor and type: edit javaclasspath.txt in the Command Window, and in that file add the file path to the Event Store JDBC client:
  * E.g. `/<path where the JDBC jar was placed>/ibm-db2-eventstore-jdbcdriver.jar`
3. (AFTER UPDATING javaclasspath.txt restart MATLAB or look at this for reference: https://www.mathworks.com/matlabcentral/answers/103763-why-does-the-contents-of-javaclasspath-txt-not-get-added-to-the-static-class-path-when-i-double-clic)
4. Go to the Apps tab in Matlab app and select Database Explorer
5. Select Configure Data Source and select "Configure JDBC Data Source" from the drop down menu
6. In the JDBC Data Source Configuration Editor window do the following:
  * Enter any new name for the data source, e.g. `EventStoreJDBC`
  * Enter `OTHER` as the vendor
  * For Driver enter: `org.apache.hive.jdbc.HiveDriver`
  * In URL, add in the following: `jdbc:hive2://<your eventstore JDBC IP>:12015/default`, e.g. `jdbc:hive2://9.30.252.57:12015/default`
  * Then click on any part of the window and the TEST button will pop up
  * Select TEST and you will be asked for a userid and password, where you can enter the eventstore userid and password for your system (e.g. `admin` and `password`)
  * Then you close the window. 
7. If you select and expand the default schema you will see the tables that exist in Event Store. You can expand on any of the tables and see the columns for each table. If you select the checkbox for one of the tables, a `select * from default.<tablename>` will who up in the query editor view, and if you select a subset of the columns for that table then the query will automatically only select those columns. In both cases, the query result will be displayed. If after you select a table, you can then select the Join icon at the top of the Database Explorer view, and in that view you can select another table and the join columns to view the join query and the query result.
8. Then in the Database Explore window, select the "New Query" icon which will ask for the Data Source, Username and Password. Enter the "Name" used from the JDBC window above (where it should be displayed in a drop down menu under Data Source, e.g. `EventStoreJDBC`), and enter the eventstore userid and password. Note that in this New query editor view, one can optionally use or not use the default schema name for the Event Store table(s).
