import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package

// JDK 1.7 and above
public class ExampleJdbcApp {   // Save as "JdbcSelectTest.java"

   public static void main(String[] args) {
       String driverName = "com.ibm.db2.jcc.DB2Driver";
       Connection conn = null;
       Statement stmt = null;
       try {
           try {
                   Class.forName(driverName);
                   System.out.println("After class set");
           } catch(Exception ex) {
                   System.out.println("Could not find the driver class");
           }

           // Step 1: Allocate a database 'Connection' object
           System.out.println("Connecting to a selected database...");

           conn =
           DriverManager.getConnection(
                    "jdbc:db2://9.30.119.26:18730/EVENTDB:sslConnection=true;" +
	   	    "sslTrustStoreLocation=/user-home/_global_/eventstore/eventstore/clientkeystore;" +
	   	    "sslKeyStoreLocation=/user-home/_global_/eventstore/eventstore/clientkeystore;" +
                    "sslKeyStorePassword=LdsdUbGSyYF3;" +
                    "sslTrustStorePassword=LdsdUbGSyYF3;" +
                    "securityMechanism=15;" +
                    "pluginName=IBMPrivateCloudAuth;", 
                    "admin", "password");

	   System.out.println("Connected database successfully...");
           stmt = conn.createStatement();

           // Step 2: delete old table if exist
           System.out.println("Deleting table in given database...");

           String sql = "DROP TABLE TEST10";
           try{
               stmt.executeUpdate(sql);
           }catch (SQLSyntaxErrorException ex){
               ex.printStackTrace();        
           }
           
           System.out.println("Table deleted in given database...");

           // Step 3: create new table
           System.out.println("Creating table in given database...");
           
           sql= "create table TEST10 " +
                "(DEVICEID INTEGER NOT NULL, " +
                "SENSORID INTEGER NOT NULL, " +
                "TS BIGINT NOT NULL, " +
                "AMBIENT_TEMP DOUBLE NOT NULL, " +
                "POWER DOUBLE NOT NULL, " +
                "TEMPERATURE DOUBLE NOT NULL, " +
                "CONSTRAINT \"TEST1INDEX\" " +
                "PRIMARY KEY(DEVICEID, SENSORID, TS) " +
                "include(TEMPERATURE)) " +
                "DISTRIBUTE BY HASH (DEVICEID, SENSORID) " +
                "organize by column stored as parquet";

           stmt.executeUpdate(sql);
           System.out.println("Created table in given database...");

           // Step 4: insert new lines
           sql = "INSERT INTO TEST10 " +
                 "VALUES (1,48,1541019342393,25.983183481618322,14.65874116573845,48.908846094198)";
           stmt.executeUpdate(sql);

           sql = "INSERT INTO TEST10 " +
                 "VALUES (1,24,1541019343497,22.54544424024718,9.834894630821138,39.065559149361725)";
           stmt.executeUpdate(sql);

           sql = "INSERT INTO TEST10 " +
                 "VALUES (2,39,1541019344356,24.3246538655206,14.100638100780325,44.398837306747936)";
           stmt.executeUpdate(sql);

           sql = "INSERT INTO TEST10 " +
                 "VALUES (2,1,1541019345216,25.658280957413456,14.24313156331591,45.29125502970843)";
           stmt.executeUpdate(sql);

           // Step 5: read table
           sql = "SELECT DEVICEID,SENSORID,TS,AMBIENT_TEMP,POWER,TEMPERATURE FROM TEST10";
           ResultSet rs = stmt.executeQuery(sql);
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
           rs.close();
           // Step 2: check if table exists
//           ResultSet resGetT = conn.getMetaData().getTables( null, "admin", "test1", new String[]{"TABLE"});
//           System.out.println("Show getTables:");
//           while ( resGetT.next() ) {
//              System.out.println("Found table cat: " + resGetT.getString(1) + 
//                                 " schema: " + resGetT.getString(2) +
//                                 ", Name: " + resGetT.getString(3) + 
//                                 ", Type: " + resGetT.getString(4) );
//           }
//           conn.close();
       } catch(SQLException ex){
           ex.printStackTrace();
       } finally{
           try{
              if(stmt!=null)
                 stmt.close();
           } catch(SQLException se){
           }// do nothing
           try{
              if(conn!=null)
                 conn.close();
           }catch(SQLException se){
               se.printStackTrace();
           }//end finally try
       }//end try
   }
}
