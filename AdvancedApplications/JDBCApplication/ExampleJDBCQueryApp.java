import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package
import java.util.*;
import java.io.*;
// JDK 1.7 and above
public class ExampleJDBCQueryApp {   // Save as "ExampleJDBCQueryApp.java"

   /** Name of the database that is created at the beginning and dropped at the
    *  end of this program. A database with this name must not already exist. */
   private static final String DATABASE_NAME  = "EVENTDB";

   /** Name of table to create */
   private static final String TABLE_NAME = "IOT_TEMP"; 

   /** Path for external table csv file */
   private static final String EXTERNAL_CSV_PATH= "/root/db2eventstore-IoT-Analytics/data/sample_IOT_table.csv";
    
   /** User name of database account */
   private static final String USERNAME = System.getenv("EVENT_USER");
  
   /** Password of database account */
   private static final String PASSWORD = System.getenv("EVENT_PASSWORD");

   /** SSL Keystore localtion */
   private static final String KEYDB_PATH= System.getenv("KEYDB_PATH");

   /** SSL Keystore localtion */
   private static final String KEYDB_PASSWORD = System.getenv("KEYDB_PASSWORD");

   /** Virtual IP of database server*/
   private static final String IP = System.getenv("IP");

   public static void main(String[] args) {
       String driverName = "com.ibm.db2.jcc.DB2Driver";
       Connection conn = null;
       Statement stmt = null;
       ResultSet rs = null;
       String sql = null;

       try {
           try {
                   Class.forName(driverName);
                   System.out.println("After class set");
           } catch(Exception ex) {
                   System.out.println("Could not find the driver class");
           }
           
           // Step 1: Allocate a database 'Connection' object
           System.out.println("Connecting to a selected database...");

           // Establish connection with ssl and user credentials
           conn =
                DriverManager.getConnection(
                "jdbc:db2://" + IP + ":18730/" + DATABASE_NAME + ":" +
                "sslConnection=true;" +
                "sslTrustStoreLocation="+ KEYDB_PATH + ";" +
                "sslKeyStoreLocation="+ KEYDB_PATH + ";" +
                "sslKeyStorePassword="+ KEYDB_PASSWORD + ";" +
                "sslTrustStorePassword="+ KEYDB_PASSWORD + ";" +
                "securityMechanism=15;" +
                "pluginName=IBMPrivateCloudAuth;", 
                USERNAME, PASSWORD);

           // Set Isolation level to be able to query data immediately after it is inserted
           conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

	   // Connect to database
	   stmt = conn.createStatement();
	   System.out.println("Connected database successfully...");

           // Please write your own query or uncomment the blocks if needed
           
           /********************************************************************************
            *                         Basic Event Store Queries                            *
            *                                                                              *
            ********************************************************************************/

           // Get the total row number of table 
           /*
             sql = "SELECT count(*) FROM " + TABLE_NAME;
             rs = stmt.executeQuery(sql);
 	     while(rs.next()) {
 	          System.out.println("Total number of rows: " + rs.getInt(1));
 	      }
            */

           // Show one row within table
           /* 
             sql = "SELECT * FROM " + TABLE_NAME + " LIMIT 1";
             rs = stmt.executeQuery(sql);
             while(rs.next()) {
                 int deviceID = rs.getInt("DEVICEID");
                 int sensorID = rs.getInt("SENSORID");
                 long ts = rs.getLong("TS");
                 double ambient_temp = rs.getDouble("AMBIENT_TEMP");
                 double power = rs.getDouble("POWER");
                 double temp = rs.getDouble("TEMPERATURE");
            
                 // display data
                 System.out.print("deviceID: " + deviceID);
                 System.out.print(", sensorID: " + sensorID);
                 System.out.print(", ts: " + ts);
                 System.out.print(", ambient_temp: " + ambient_temp);
                 System.out.print(", power: " + power);
                 System.out.println(", temperature: " + temp);
             } 
            */
           
           // Get the minimum and maximum timestamp from table
           /* 
             sql = "SELECT MIN(ts) AS MINTS, MAX(ts) AS MAXTS FROM " + TABLE_NAME; 
             rs = stmt.executeQuery(sql);
             while(rs.next()) {
                 System.out.print("MIN(ts): "+ rs.getLong("MINTS") + " ");
                 System.out.println("MAX(ts): "+ rs.getLong("MAXTS"));
             }
            */

           /********************************************************************************
            *                     Optimal query through the index                          *
            *                                             				   *
            * - Index queries will significantly reduce amount of data that needs to be    *
            *   scanned for results.							   *
            *    - Indexes in IBM Db2 Event Store are formed asynchronously to avoid  	   *
            *      insert latency.                					   *
            *    - They are stored as a Log Structured Merge (LSM) Tree.	           *
            *    - The index is formed by "runs", which include sequences of sorted keys.  *
            *    - These runs are written to disk during "Share" processing.               *
            *      These index runs are merged together over time to improve scan and      *
            *      I/O efficiency.                                                         *
            * - For an optimal query performance you must specify equality on all the      *
            *   equal_columns in the index and a range on the sort column in the index.    *
            *   								           *
            ********************************************************************************/

           /* For example, in the following query we are retrieving all the values in the 
            * range of dates for a specific device and sensor, where both the deviceID and 
            * sensorID are in the equal_columns definition for the index schema and the ts 
            * column is the sort column for the index.
            */

           /* 
             sql = "SELECT ts, temperature  FROM " + TABLE_NAME + " " +
                   "where deviceID=1 and sensorID=12 and " + 
                   "ts > 1541021271619 and ts < 1541043671128 order by ts";
             rs = stmt.executeQuery(sql);
             while(rs.next()) {
                 long ts = rs.getLong("TS");
                 double temp = rs.getDouble("TEMPERATURE");
                
                 // display data
                 System.out.print("ts: " + ts);
                 System.out.println(", temperature: " +  temp);
             }
            */

            /********************************************************************************
             *                            Sub-optimal query                                 *
             * 										    *
             * - Sub-optimal query only specifies equality in one of the equal_columns in   *
             *   the index schema, and for this reason ends up doing a full scan of         *
             *   the table. 								    *
             *   									    *
             ********************************************************************************/

           /* The following query demonstrates a sub-optimal query where we only search 
 	    * rows with the equality column being "sensorID".
 	    */

           /*
             sql = "SELECT count(*)  FROM " + TABLE_NAME + " where sensorID = 7";
             rs = stmt.executeQuery(sql);
             while(rs.next()) {
                 System.out.println("Total number of rows where sensorID = 7: " + rs.getInt(1));
              }
            */

           /********************************************************************************
            *                   Accessing multiple sensorIDs optimally                     *
            *										   *
            * - The easiest way to write a query that needs to retrieve multiple values    *
            *   in the equal_columns in the index schema is by using an In-List.           *
            *   With this, you can get optimal index access across multiple sensorID's.    *
            *                                                                              *
            ********************************************************************************/
            
           /* In this example we specify equality for a specific deviceID, and an In-List 
            * for the four sensors we are trying to retrieve. To limit the number of records 
            * we are returning we also include a range of timestamps.
            */

           /*
             sql = "SELECT deviceID, sensorID, ts  FROM " + TABLE_NAME + " " + 
                   "where deviceID=1 and sensorID in (1, 5, 7, 12) and " + 
                   "ts >1541021271619 and ts < 1541043671128 order by ts";
             rs = stmt.executeQuery(sql);
             while(rs.next()) {
                 int deviceID = rs.getInt("DEVICEID");
                 int sensorID = rs.getInt("SENSORID");
                 long ts = rs.getLong("TS");

                 // display data
                 System.out.print("deviceID: " + deviceID);
                 System.out.print(", sensorID: " + sensorID);
                 System.out.print("ts: " + ts);
             }
            */

           /*
             sql = <Please place your query here>;
             rs = stmt.executeQuery(sql);
             while(rs.next()){
                 <logics for processing the data>
             }
            */

       } catch(SQLException ex){
           ex.printStackTrace();
       } finally{
           try{
              if(rs!=null)
                 rs.close();
           } catch(SQLException se){
                se.printStackTrace();
           }
           try{
              if(stmt!=null)
                 stmt.close();
           } catch(SQLException se){
                 se.printStackTrace();
           }
           try{
              if(conn!=null)
                 conn.close();
           }catch(SQLException se){
               se.printStackTrace();
           }//end finally try
       }//end try
   }
}
