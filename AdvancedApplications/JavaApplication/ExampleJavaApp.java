  import com.ibm.event.catalog.ColumnOrder;
  import com.ibm.event.catalog.IndexSpecification;
  import com.ibm.event.catalog.SortSpecification;
  import com.ibm.event.catalog.TableSchema;
  import com.ibm.event.oltp.InsertResult;
  import com.ibm.event.oltp.EventContext;
  import com.ibm.event.common.ConfigurationReader;
  import org.apache.spark.sql.Dataset;
  import org.apache.spark.sql.Row;
  import org.apache.spark.sql.SparkSession;
  import org.apache.spark.sql.ibm.event.EventSession;
  import org.apache.spark.sql.catalyst.expressions.GenericRow;
  import org.apache.spark.sql.types.DataType;
  import org.apache.spark.sql.types.DataTypes;
  import org.apache.spark.sql.types.StructField;
  import org.apache.spark.sql.types.StructType;
  import scala.Option;
  import scala.None;
  import scala.collection.JavaConversions;
  import scala.collection.Seq;
  import scala.concurrent.Await;
  import scala.concurrent.Future;
  import scala.concurrent.duration.Duration;

  import java.util.ArrayList;
  import java.util.Arrays;
  import java.util.List;
  import java.util.Random;

  /**
   * A simple Java class that invokes the EventContext.
   * It performs the following steps
   * (1) connect to database "EVENTDB"
   * (2) drop table if exists
   * (3) creates the table
   * (4) asynchronously inserts a batch of rows into the table
   * (5) Open a EventSession and run a query against the table (SELECT * FROM <TABLE_NAME>)*
   */
  public class ExampleJavaApp {

      /** Name of the database that is created at the beginning and dropped at the
       * end of this program. A database with this name must not already exist. */
      private static final String DATABASE_NAME  = "EVENTDB";

      /** Name of table to create */
      private static final String TABLE_NAME = "JavaTable"; 

      /** SparkSQL Query to run on table */
      private static final String QUERY = "SELECT * FROM "+TABLE_NAME;
      
      public static void main(String args[]) {

          // Set connection endpoints
          ConfigurationReader.setConnectionEndpoints("9.30.119.26:18730;9.30.119.26:1101");
          // Set user credential
          ConfigurationReader.setEventUser("admin");
          ConfigurationReader.setEventPassword("password");
          // Define schema of table as SparkSQL StructType
          StructField[] tabFields = new StructField[] {
              DataTypes.createStructField("deviceID", DataTypes.IntegerType, false),
              DataTypes.createStructField("sensorID", DataTypes.IntegerType, false),
              DataTypes.createStructField("ts", DataTypes.LongType, false),
              DataTypes.createStructField("ambient_temp", DataTypes.DoubleType, false),
              DataTypes.createStructField("power", DataTypes.DoubleType, false),
              DataTypes.createStructField("temperature", DataTypes.DoubleType, false)
          };
          StructType tabSchemaStruct = DataTypes.createStructType(tabFields);

          // Create IBM Db2 Event Store table schema
          // For interoperability with the Scala API, the scala collection types are created from
          // the corresponding Java collection types.
          Seq<String> pkColumns = JavaConversions.asScalaBuffer(Arrays.asList("deviceID", "sensorID", "ts")).toSeq();
          Seq<String> shardColumns = JavaConversions.asScalaBuffer(Arrays.asList("deviceID", "sensorID")).toSeq();
          //Option<Seq<String>> emptyPart = Option.empty();

          TableSchema tabSchema = new TableSchema(
                  TABLE_NAME,          // table name
                  tabSchemaStruct,     // schema SparkSQL TypeStruct
                  shardColumns,        // sharding key: list of columns that form composite sharding key
                  pkColumns,           // primary key: list of columns that form composite primary key
		  Option.empty()
          );

          Seq<String> equalColumns = JavaConversions.asScalaBuffer(Arrays.asList("deviceID", "sensorID")).toSeq();
          Seq<SortSpecification> SortColumns = JavaConversions.asScalaBuffer(
		  Arrays.asList(new SortSpecification("ts", ColumnOrder.DescendingNullsLast()))).toSeq();
          Seq<String> includeColumns = JavaConversions.asScalaBuffer(Arrays.asList("temperature")).toSeq();
          // Create index specification along with table
          IndexSpecification indexSpec = new IndexSpecification(
                  TABLE_NAME+"Index",     // index name
                  tabSchema,              // table schema
                  equalColumns,           // list of equality columns
                  SortColumns,            // list of sort columns
                  includeColumns,         // list of include columns
                  Option.apply(null));    // IndexID: None (will be engine generated)

          // Connect to database
          System.out.println("Connect to database "+DATABASE_NAME);
          EventContext ctx = EventContext.getEventContext(DATABASE_NAME);

	  // Drop table if exists
          try {
       	      System.out.println("droping table "+tabSchema.tableName());
              ctx.dropTable(TABLE_NAME);
          } catch(Exception e){
              if(!e.getMessage().contains("SQLCODE=-204")) throw e;
              else System.out.println("Table not found, skip dropping table");
          }

          // Create table with index
          System.out.println("creating table "+tabSchema.tableName());
          ctx.createTableWithIndex(tabSchema, indexSpec);

          // Generate one batch of row and insert it asynchronously into table.
          System.out.println("asynchronously inserting rows as batch");

          List<Row> rows = new ArrayList<>();
	  rows.add(new GenericRow(new Object[]
		  {1,48,1541019342393L,25.983183481618322,14.65874116573845,48.908846094198}));
          rows.add(new GenericRow(new Object[]
		  {1,24,1541019343497L,22.54544424024718,9.834894630821138,39.065559149361725}));
          rows.add(new GenericRow(new Object[]
		  {2,39,1541019344356L,24.3246538655206,14.100638100780325,44.398837306747936}));
          rows.add(new GenericRow(new Object[]
		  {2,1,1541019345216L,25.658280957413456,14.24313156331591,45.29125502970843}));
          rows.add(new GenericRow(new Object[]
		  {2,20,1541019346515L,26.836546274856012,12.841557839205619,48.70012987940281}));

          Future<InsertResult> future = ctx.batchInsertAsync(ctx.getTable(TABLE_NAME),
                  JavaConversions.asScalaBuffer(rows).toIndexedSeq(), true);
          try {
              // Wait for insert to complete and check outcome
              InsertResult result = Await.result(future, Duration.Inf());
              if (result.successful()) {
                  System.out.println("batch insert successful");
              } else {
                  System.out.println("batch insert failed: "+result);
                  // if required, retry using `result.retryFailed()`
              }
          } catch(Exception e) {
              System.out.println("Await threw exception: "+e);
              e.printStackTrace();
          }

          EventContext.cleanUp();

          // Create new IBM Db2 Event Store Spark Session
          System.out.println("create EventSession");
          SparkSession sparkSession = SparkSession.builder().master("local[3]")
                  .appName("ExampleJavaApp").getOrCreate();
          EventSession sqlContext = new EventSession(sparkSession.sparkContext(),
                  DATABASE_NAME);

          // Open the database and register the table in the Spark catalog
          System.out.println("open database and table "+TABLE_NAME+" with SparkSQL");
          sqlContext.openDatabase();
          sqlContext.setQueryReadOption("SnapshotNone");
          sqlContext.loadEventTable(TABLE_NAME).createOrReplaceTempView(TABLE_NAME);

          // Run query and show NUM_QUERY_RESULT rows of the query result
          System.out.println("execute query: "+QUERY);
          Dataset<Row> results = sqlContext.sql(QUERY);
          results.show();

          // Drop database
          System.out.println("done.");
      }
  }
