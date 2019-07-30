import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package

// JDK 1.7 and above
public class ExampleJDBCApp {   // Save as "ExampleJDBCApp.java"

   /** Name of the database that is created at the beginning and dropped at the
    *  end of this program. A database with this name must not already exist. */
   private static final String DATABASE_NAME  = "EVENTDB";

   /** Name of table to create */
   private static final String TABLE_NAME = "JdbcTable"; 

   /** Path for external table csv file */
   private static final String EXTERNAL_CSV_PATH= "/root/db2eventstore-IoT-Analytics/data/sample_IOT_table.csv";

   public static void main(String[] args) {
       String driverName = "com.ibm.db2.jcc.DB2Driver";
       Connection conn = null;
       Statement stmt = null;
       ResultSet rs = null;
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
                    "jdbc:db2://9.30.119.26:18730/" + DATABASE_NAME + ":sslConnection=true;" +
	   	    "sslTrustStoreLocation=/var/lib/eventstore/clientkeystore;" +
	   	    "sslKeyStoreLocation=/var/lib/eventstore/clientkeystore;" +
                    "sslKeyStorePassword=LdsdUbGSyYF3;" +
                    "sslTrustStorePassword=LdsdUbGSyYF3;" +
                    "securityMechanism=15;" +
                    "pluginName=IBMPrivateCloudAuth;", 
                    "admin", "password");

           // Set Isolation level to be able to query data immediately after it is inserted
           conn.setTransactionIsolation(Connection.TRANSACTION_READ_UNCOMMITTED);

           // Please write your own query and uncomment the line if needed
           /** sql = <Please place your query here> 
             * rs = stmt.executeQuery(sql);
             * while(rs.next()){
             *
             * }
             */

           // close result set
           rs.close();

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
