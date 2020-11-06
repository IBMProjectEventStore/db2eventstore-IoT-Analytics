import com.ibm.event.oltp.{EventContext,InsertResult}
import com.ibm.event.common.ConfigurationReader
import org.apache.spark.sql.ibm.event.EventSession
import com.ibm.event.catalog.{TableSchema,IndexSpecification,SortSpecification,ColumnOrder}
import org.apache.spark.sql.types._
import org.apache.spark.sql.Row
import org.apache.spark.{SparkConf, SparkContext}
import scala.concurrent._
import scala.concurrent.duration._

object ExampleScalaAppNoSSL {

  def main(args: Array[String]): Unit = {
    // set db2 connection endpoint
    val ip = sys.env("IP")
    val db2port = sys.env("DB2_PORT")
    val esport = sys.env("ES_PORT")
    println(s"Connecting to $ip;")
    ConfigurationReader.setConnectionEndpoints(s"$ip:$db2port;$ip:$esport")
    ConfigurationReader.setConnectionTimeout(10)
    
    // set user credential
    ConfigurationReader.setEventUser(sys.env("EVENT_USER"))
    ConfigurationReader.setEventPassword(sys.env("EVENT_PASSWORD"))

    // set ssl credentials to No SSL
    ConfigurationReader.setSSLEnabled(false)

    // database information
    val dbName = "EVENTDB"
    println(s"Using database $dbName")
    val ctx = EventContext.getEventContext(dbName)
    
    // define table structure
    val tabName = "SCALATABLE"

    val tabSchema = TableSchema(tabName, StructType(Array(
   	StructField("deviceID", IntegerType, nullable = false),
   	StructField("sensorID", IntegerType, nullable = false),
   	StructField("ts", LongType, nullable = false),
   	StructField("ambient_temp", DoubleType, nullable = false),
   	StructField("power", DoubleType, nullable = false),
   	StructField("temperature", DoubleType, nullable = false)
        )),
    	shardingColumns = Array("deviceID", "sensorID"),
   	pkColumns = Array("deviceID", "sensorID", "ts")
    )

    val indexSpec = IndexSpecification(
        indexName=tabName + "Index",
        tableSchema=tabSchema,
        equalColumns = Array("deviceID", "sensorID"),
        sortColumns = Array(
          SortSpecification("ts", ColumnOrder.DescendingNullsLast)),
        includeColumns = Array("temperature")
    ) 

    try {
        println("Trying to drop table if it exists")
        ctx.dropTable(tabName)
    } catch {
        case e: Exception =>
        val TableNotFound = e.getMessage.split(" ").contains("SQLCODE=-204,")
        if (TableNotFound) {
            println("Table not found." + e.getMessage)
        } else {
            println("EXCEPTION: Exception during drop table. Trying to exit..." + e.getMessage)
            e.printStackTrace()
            sys.exit(1)
        }
    }

    println("Creating table " + tabName)
    var res = ctx.createTableWithIndex(tabSchema, indexSpec)
    assert(res.isEmpty, s"create table: ${res.getOrElse("success")}")
    val tab = ctx.getTable(tabName)
    println("Table schema = " + tab )

    // insert into the table
    println("Inserting into table " + tabName)

    val batch = IndexedSeq(Row(1,48,1541019342393L,25.983183481618322,14.65874116573845,48.908846094198),
                    Row(1,24,1541019343497L,22.54544424024718,9.834894630821138,39.065559149361725),
                    Row(2,39,1541019344356L,24.3246538655206,14.100638100780325,44.398837306747936),
                    Row(2,1,1541019345216L,25.658280957413456,14.24313156331591,45.29125502970843),
                    Row(2,20,1541019346515L,26.836546274856012,12.841557839205619,48.70012987940281),
                    Row(1,24,1541019347200L,24.960868340037266,11.773728418852778,42.16182979507462))

    val future: Future[InsertResult] = ctx.batchInsertAsync(tab, batch)
    val result: InsertResult = Await.result(future, Duration.Inf)
    if (result.failed) 
        println(s"Batch insert incomplete: $result")
    else 
        println(s"Batch successfully inserted into $tabName")

    EventContext.cleanUp()

    // query from table
    val sc = new SparkContext(new SparkConf().setAppName("ExampleScalaApp").setMaster(
        Option(System.getenv("MASTER")).getOrElse("local[3]")))
    try {
      val sqlContext = new EventSession(sc, dbName)
      sqlContext.openDatabase()
      sqlContext.setQueryReadOption("SnapshotNone")
      val ads = sqlContext.loadEventTable(tabName)
      println(ads.schema)
      ads.createOrReplaceTempView(tabName)
      val results = sqlContext.sql(s"SELECT * FROM $tabName")
      results.show()
    } catch {
      case e: Exception =>
        println("EXCEPTION: attempting to exit..." + e.getMessage)
        e.printStackTrace()
        sys.exit(1)
    }
    sys.exit()
  }
}
