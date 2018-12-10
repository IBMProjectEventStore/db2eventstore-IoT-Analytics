import java.sql.*;   // Use 'Connection', 'Statement' and 'ResultSet' classes in java.sql package
 
// JDK 1.7 and above
public class ExampleJDBCApp { 

   public static void main(String[] args) {
       String driverName = "org.apache.hive.jdbc.HiveDriver";
 
      try {
		try {
                        Class.forName(driverName);
         		System.out.println("After class set"); 
      		} catch(Exception ex) {
			System.out.println("Could not find the driver class");
                }

         	// Step 1: Allocate a database 'Connection' object
         	Connection conn = 
	  	DriverManager.getConnection(
				"jdbc:hive2://172.16.180.33:12015/TESTDB", "admin", "password");
 
                System.out.println("Connected");

		DatabaseMetaData databaseMetaData = conn.getMetaData();

		//Print TABLE_TYPE "TABLE"
		ResultSet resultSet = databaseMetaData.getTables(null, null, null, new String[]{"TABLE"});
		System.out.println("Printing TABLE_TYPE \"TABLE\" ");
		System.out.println("----------------------------------");
		while(resultSet.next())
		{
    			System.out.println(resultSet.getString("TABLE_NAME"));
		}

                ResultSet resGet = conn.getMetaData().getTables( null, null, null, null );
                System.out.println("Show getTables:");
                while ( resGet.next() ) {
                        System.out.println("Found table cat: " + resGet.getString(1) + " schema: " + resGet.getString(2) + 
					", Name: " + resGet.getString(3) + ", Type: " + resGet.getString(4) );
                }

		System.out.println("Test case sensitive:" );

                ResultSet resGetT = conn.getMetaData().getTables( null, "default", "tab1", null );
                System.out.println("Show getTables:");
                while ( resGetT.next() ) {
                        System.out.println("Found table cat: " + resGetT.getString(1) + " schema: " + resGetT.getString(2) + 
					", Name: " + resGetT.getString(3) + ", Type: " + resGetT.getString(4) );
                }

                ResultSet resGet2 = conn.getMetaData().getColumns( null, null, null, null );
                System.out.println("Show getColumns:");
                while ( resGet2.next() ) {
    
                        System.out.println("Found table cat: " + resGet2.getString(1) + " schema: " + resGet2.getString(2) + 
				", Name: " + resGet2.getString(3) + 
				", Col name: " + resGet2.getString(4) + 
        			" data type: " + resGet2.getInt(5) + " type: " + resGet2.getString(6) +
        			" size: " + resGet2.getInt(7) );

                }

                ResultSet resGetTy = conn.getMetaData().getTableTypes();
                System.out.println("Show getTableTypes:");
                while ( resGetTy.next() ) {
                        System.out.println("Found table type: " + resGetTy.getString(1) );
                }

		String resGetD = conn.getMetaData().getDriverVersion();
                System.out.println("Show getDriver:" + resGetD);

                ResultSet resGetC = conn.getMetaData().getCatalogs();
                System.out.println("Show getCatalogs:");
                while ( resGetC.next() ) {
			System.out.println(resGetC.getString(1));
                }

                ResultSet resGetS = conn.getMetaData().getSchemas();
                System.out.println("Show getSchemas:");
                while ( resGetS.next() ) {
			System.out.println( "Schema: " + resGetS.getString(1) + " catalog:  " + resGetS.getString(2));
                }


         // Step 2: Allocate a 'Statement' object in the Connection
         Statement stmt = conn.createStatement();
      
	 String tableName = "tab1";
 
	// show tables
	String sql = "show tables '" + tableName + "'";
	System.out.println("Running: " + sql);
	ResultSet res = stmt.executeQuery(sql);
	if (res.next()) {
		System.out.println(res.getString(1));
	}
 
        // describe table
	sql = "describe " + tableName;
	System.out.println("Running: " + sql);
	res = stmt.executeQuery(sql);
	while (res.next()) {
	   System.out.println(res.getString(1) + "\t" + res.getString(2) + "\t" + res.getString(2));
	}
	    
	sql = "select * from " + tableName;
	System.out.println("Running: " + sql);
	res = stmt.executeQuery(sql);

	ResultSetMetaData rsmd = res.getMetaData();
    	int numberOfColumns = rsmd.getColumnCount();
	System.out.println( "num cols = " + numberOfColumns );
	for( int i =1; i<numberOfColumns; i++ ){
	  System.out.println( "Col " + i + " name: " + rsmd.getColumnName(i) +
		" type: " + rsmd.getColumnTypeName(i) );
	}

        int count = 0;
        System.out.println( "Output result:" );
	while (res.next() && count < 100) {
		System.out.println("Row output: " + res.getInt(1) + " " + res.getString(2));
    		count = count + 1;
	}
         System.out.println("Total number of records = " + count);


      // Step 5: Close the resources - Done automatically by try-with-resources
	res.close();
	stmt.close();
	conn.close();
 
      } catch(SQLException ex) {
         ex.printStackTrace();
      }
   }
}

