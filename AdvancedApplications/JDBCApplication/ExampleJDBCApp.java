import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package
import java.util.*;
import java.io.*;

// JDK 1.7 and above
public class ExampleJDBCApp {   // Save as "ExampleJDBCApp.java"

   /** Name of the database that is created at the beginning and dropped at the
    *  end of this program. A database with this name must not already exist. */
   private static final String DATABASE_NAME  = "EVENTDB";

   /** Name of table to create */
   private static final String TABLE_NAME = "IOT_TEMP"; 

   /** Path for external table csv file */
   private static final String EXTERNAL_CSV_PATH = "/root/db2eventstore-IoT-Analytics/data/sample_IOT_table.csv";

   /** User name of database account */
   private static final String USERNAME = System.getenv("EVENT_USER");
  
   /** Password of database account */
   private static final String PASSWORD = System.getenv("EVENT_PASSWORD");

   /** Virtual IP of database server*/
   private static final String IP = System.getenv("IP");

   public static void main(String[] args) {
       String driverName = "com.ibm.db2.jcc.DB2Driver";
       Connection conn = null;
       Statement stmt = null;
       ResultSet rs = null;
       String KEYDB_PASSWORD = null;
       String KEYDB_PATH = null;
       try {
           try {
                   Class.forName(driverName);
                   System.out.println("After class set");
           } catch(Exception ex) {
                   System.out.println("Could not find the driver class");
           }

        File bluspark =new File("/bluspark/external_conf/bluspark.conf");
        Scanner in = null;
        try {
            in = new Scanner(bluspark);
            while(in.hasNext())
            {
                String line=in.nextLine();
                if(line.contains("sslKeyStorePassword"))
                    { KEYDB_PASSWORD = line.split(" ")[1];}
                if(line.contains("sslKeyStoreLocation"))
                { KEYDB_PATH = line.split(" ")[1];}
            }
        } catch (FileNotFoundException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
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
           
           // Step 2: delete old table if exist
           System.out.println("Deleting table in given database...");

           String sql = "DROP TABLE " + TABLE_NAME;
           try{
               stmt.executeUpdate(sql);
               System.out.println("Table deleted in given database...");
           }catch (SQLSyntaxErrorException ex){
               // Error other than table not exist
               if(!ex.getMessage().contains("SQLCODE=-204")) throw ex;
               // Table not exist
               else System.out.println("Table not found, skip dropping table");
           }
           
           // Step 3: create new table
           System.out.println("Creating table in given database...");
           
           sql= "create table " + TABLE_NAME + " " +
                "(DEVICEID INTEGER NOT NULL, " +
                "SENSORID INTEGER NOT NULL, " +
                "TS BIGINT NOT NULL, " +
                "AMBIENT_TEMP DOUBLE NOT NULL, " +
                "POWER DOUBLE NOT NULL, " +
                "TEMPERATURE DOUBLE NOT NULL, " +
                "CONSTRAINT \"TEST1INDEX\" " +
                "PRIMARY KEY(DEVICEID, SENSORID, TS)) " +
                "DISTRIBUTE BY HASH (DEVICEID, SENSORID) " +
                "organize by column stored as parquet";

           stmt.executeUpdate(sql);
           System.out.println("Created table in given database...");

           // Step 4: insert new rows
           System.out.println("Insert row: 99,48,1541019342393,25.983183481618322,14.65874116573845,48.908846094198");
           sql = "INSERT INTO " + TABLE_NAME + " " +
                 "VALUES (99,48,1541019342393,25.983183481618322,14.65874116573845,48.908846094198)";
           stmt.executeUpdate(sql);

           System.out.println("Insert row: 99,24,1541019343497,22.54544424024718,9.834894630821138,39.065559149361725");
           sql = "INSERT INTO " + TABLE_NAME + " " +
                 "VALUES (99,24,1541019343497,22.54544424024718,9.834894630821138,39.065559149361725)";
           stmt.executeUpdate(sql);
  
           System.out.println("Insert row: 99,39,1541019344356,24.3246538655206,14.100638100780325,44.398837306747936");         
           sql = "INSERT INTO " + TABLE_NAME + " " +
                 "VALUES (99,39,1541019344356,24.3246538655206,14.100638100780325,44.398837306747936)";
           stmt.executeUpdate(sql);

           System.out.println("Insert row: 99,1,1541019345216,25.658280957413456,14.24313156331591,45.29125502970843");
           sql = "INSERT INTO " + TABLE_NAME + " " +
                 "VALUES (99,1,1541019345216,25.658280957413456,14.24313156331591,45.29125502970843)";
           stmt.executeUpdate(sql);

           // Step 5: insert from external table
           System.out.println("Insert from external table: " + EXTERNAL_CSV_PATH);
           sql = "INSERT INTO " + TABLE_NAME + " " +
                 "SELECT * FROM external '" + EXTERNAL_CSV_PATH + "' LIKE " + TABLE_NAME + " " +
                 "USING (delimiter ',' MAXERRORS 10 SOCKETBUFSIZE 30000 REMOTESOURCE 'JDBC' )";
           stmt.executeUpdate(sql);

           // Step 6: get column name of table
           DatabaseMetaData databaseMetaData = conn.getMetaData();
           rs = databaseMetaData.getColumns(null, USERNAME.toUpperCase(), TABLE_NAME, null);
           System.out.println("Table columns:");
           while (rs.next()){
              String columnName = rs.getString("COLUMN_NAME");
              System.out.print(columnName + "  ");
           }
           System.out.println();

           // Step 7: get number of rows in table
           sql = "SELECT count(*) FROM " + TABLE_NAME;
           rs = stmt.executeQuery(sql);
           while(rs.next()) {
               System.out.println("Totol number of Rows: " + rs.getInt(1));
           }

           // Step 8: get minimun and maximum value of timestamp
           sql = "SELECT MIN(ts) as MINTS, MAX(ts) as MAXTS FROM " + TABLE_NAME;
           rs = stmt.executeQuery(sql);
           while(rs.next()) {
               System.out.print("MIN(ts): "+ rs.getLong("MINTS") + " ");
               System.out.println("MAX(ts): "+ rs.getLong("MAXTS"));
           }

           // Step 9: read first 10 rows from table
           System.out.println("First 10 rows:");

           sql = "SELECT DEVICEID,SENSORID,TS,AMBIENT_TEMP,POWER,TEMPERATURE FROM " + TABLE_NAME + 
		 " LIMIT 10";
           rs = stmt.executeQuery(sql);
           while (rs.next()) {
               // retrieve data by column name
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
