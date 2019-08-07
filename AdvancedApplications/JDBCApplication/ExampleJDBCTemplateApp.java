import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package
import java.util.*;
import java.io.*;
// JDK 1.7 and above
public class ExampleJDBCTemplateApp {   // Save as "ExampleJDBCTemplateApp.java"

   /** Name of the database that is created at the beginning and dropped at the
    *  end of this program. A database with this name must not already exist. */
   private static final String DATABASE_NAME  = "EVENTDB";

   /** Name of table to create */
   private static final String TABLE_NAME = <please enter your table name>; 
    
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
       String sql = null;
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

           // Please write your own query or uncomment the blocks if needed

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
