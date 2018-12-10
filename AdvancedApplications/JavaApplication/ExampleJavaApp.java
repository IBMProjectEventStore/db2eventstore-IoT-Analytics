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
  import java.util.Collections;
  import java.util.List;
  import java.util.Random;

  /**
   * A simple Java class that invokes the EventContext.
   * It performs the following steps
   * (1) creates a database
   * (2) creates a table
   * (3) asynchronously inserts a batch of rows into the table
   * (4) Open a EventSession and run a query against the table (SELECT * FROM Ads)*
   * (5) drops the database
   *
   * Note: to execute one case use:
   *     java -cp target/scala-2.11/ibm-event_2.11-assembly-1.0.jar:${SPARK_HOME}/jars/* com.ibm.event.example.JavaEventStoreExample
   */
  public class ExampleJavaApp {

      /** Name of the database that is created at the beginning and dropped at the
       * end of this program. A database with this name must not already exist. */
      private static final String DATABASE_NAME  = "TESTDB";

      /** Number of rows to insert into the table */
      private static final int NUM_ROWS = 1000;

      /** SparkSQL Query to run on table */
      private static final String QUERY = "SELECT * FROM Ads";

      /** Number of rows to show from query result */
      private static final int NUM_QUERY_ROWS = 10;

      /**
       * Generate a number of random rows
       * @param schema table schema for the rows
       * @param numRows number of rows to generate
       * @return a list of rows.
       */
      private static List<Row> getRandomRows(TableSchema schema, int numRows) {
          ArrayList<Row> rows = new ArrayList<>(numRows);
          Random rnd = new Random(1234);
          for (long rowId=0; rowId<numRows; ++rowId) {

              StructField[] fields = schema.schema().fields();
              Object[] values = new Object[fields.length];
              int fieldIdx = 0;
              for (StructField field : fields) {
                  DataType dt = field.dataType();
                  if (field.name().equals("adId") && dt.equals(DataTypes.LongType)) {
                      values[fieldIdx++] = rowId;
                  } else if (dt.equals(DataTypes.IntegerType)) {
                      values[fieldIdx++] = rnd.nextInt();
                  } else if (dt.equals(DataTypes.LongType)) {
                      values[fieldIdx++] = rnd.nextLong();
                  } else if (dt.equals(DataTypes.ByteType)) {
                      values[fieldIdx++] = (byte)rnd.nextInt(256);
                  } else if (dt.equals(DataTypes.FloatType)) {
                      values[fieldIdx++] = rnd.nextFloat();
                  } else if (dt.equals(DataTypes.DoubleType)) {
                      values[fieldIdx++] = rnd.nextDouble();
                  } else if (dt.equals(DataTypes.BooleanType)) {
                      values[fieldIdx++] = rnd.nextBoolean();
                  } else {
                      throw new RuntimeException("unsupported data type: "+dt);
                  }
              }
              rows.add(new GenericRow(values));
          }
          return rows;
      }

      public static void main(String args[]) {

          // Set connection endpoints
          ConfigurationReader.setConnectionEndpoints("9.30.189.50:1101");
          // Define schema of 'Ads' table as SparkSQL StructType
          StructField[] adsFields = new StructField[] {
              DataTypes.createStructField("storeId", DataTypes.LongType, false),
              DataTypes.createStructField("adId", DataTypes.LongType, false),
              DataTypes.createStructField("categoryId", DataTypes.IntegerType, false),
              DataTypes.createStructField("productName", DataTypes.LongType, false),
              DataTypes.createStructField("budget", DataTypes.LongType, false),
              DataTypes.createStructField("cost", DataTypes.LongType, false)
          };
          StructType adsSchema = DataTypes.createStructType(adsFields);

          // Create IBM Db2 Event Store table schema
          // For interoperability with the Scala API, the scala collection types are created from
          // the corresponding Java collection types.
          Seq<String> pkList = JavaConversions.asScalaBuffer(Collections.singletonList("adId")).toSeq();
          Seq<String> emptyStringList = JavaConversions.asScalaBuffer(Collections.<String>emptyList()).toSeq();
          Seq<SortSpecification> emptySortSpecList = JavaConversions.asScalaBuffer(
                  Collections.<SortSpecification>emptyList()).toSeq();
          Option<Seq<String>> emptyPart = Option.empty();

          TableSchema adsTableSchema = new TableSchema(
                  "Ads",    // table name
                  adsSchema,          // schema SparkSQL TypeStruct
                  pkList,             // sharding key: list of columns that form composite sharding key
                  pkList,             // primary key: list of columns that form composite primary key
		  emptyPart );

          // Create index specification along with table
          IndexSpecification index = new IndexSpecification(
                  "FooIndex",   // index name
                  adsTableSchema,         // table schema
                  pkList,                 // list of equality columns
                  emptySortSpecList,      // list of sort columns
                  emptyStringList,        // list of include columns
                  Option.apply(null));    // IndexID: None (will be engine generated)

          // Create database
          System.out.println("Connect to database "+DATABASE_NAME);
          EventContext ctx = EventContext.getEventContext(DATABASE_NAME);

          ctx.dropTable("Ads");

          // Create 'Ads' table with index
          System.out.println("creating table "+adsTableSchema.tableName());
          ctx.createTableWithIndex(adsTableSchema, index);

          // Generate one batch of row and insert it asynchronously into the Ads table.
          System.out.println("asynchronously inserting rows "+NUM_ROWS+" as batch");
          Future<InsertResult> future = ctx.batchInsertAsync(ctx.getTable("Ads"),
                  JavaConversions.asScalaBuffer(getRandomRows(adsTableSchema, NUM_ROWS)).toIndexedSeq(), true);
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

          // Create new IBM Db2 Event Store Spark Session
          System.out.println("create EventSession");
          SparkSession sparkSession = SparkSession.builder().master("local[3]")
                  .appName("EventStoreExample").getOrCreate();
          EventSession session = new EventSession(sparkSession.sparkContext(),
                  DATABASE_NAME);

          // Open the database and register the table in the Spark catalog
          System.out.println("open database and table Ads with SparkSQL");
          session.openDatabase();
          session.loadEventTable("Ads").createOrReplaceTempView("Ads");

          // Run query and show NUM_QUERY_RESULT rows of the query result
          System.out.println("execute query: "+QUERY);
          Dataset<Row> results = session.sql(QUERY);
          System.out.println("result: ("+NUM_QUERY_ROWS+" result rows):");
          results.show(10);

          // Drop database
          //System.out.println("dropping database "+DATABASE_NAME);
          //EventContext.dropDatabase(DATABASE_NAME);
          System.out.println("done.");

          EventContext.cleanUp();
      }
  }
