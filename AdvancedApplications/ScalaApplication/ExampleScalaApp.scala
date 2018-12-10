import com.ibm.event.oltp.EventContext
import com.ibm.event.common.ConfigurationReader
import org.apache.spark.sql.ibm.event.EventSession
import com.ibm.event.catalog.{TableSchema,IndexSpecification,SortSpecification,ColumnOrder}
import org.apache.spark.sql.types._
import org.apache.spark.sql.Row
import org.apache.spark.{SparkConf, SparkContext}

object ExampleScalaApp {

  def main(args: Array[String]): Unit = {
    val createDB = /*false */true

    ConfigurationReader.setConnectionEndpoints("9.30.189.50:1101");
    ConfigurationReader.setConnectionTimeout(2)

    println("Please specify name of the new DB: ")
    val dbName = scala.io.StdIn.readLine()

    var ctx : EventContext = null

    if( createDB ){
    	try {
       		println(s"Dropping database $dbName")
       		EventContext.dropDatabase(dbName)
    	} catch {
        	case e: Exception =>
          		println(s"error while dropping DB: ${e.getMessage}")
    	}

    	println(s"Creating database $dbName")
        val ctx1 = EventContext.createDatabase(dbName)
    }

    println(s"Using database $dbName")
    ctx = EventContext.getEventContext(dbName)

    println("Please specify name of the new table ")
    val tabName = scala.io.StdIn.readLine()

    println("Creating table " + tabName)
    val tabSchema = TableSchema(tabName, StructType(Array(
        StructField("id", IntegerType, false),
        StructField("name", StringType, false),
	StructField("q1",ArrayType(IntegerType, containsNull = true), nullable = true),
        StructField("q2",MapType(IntegerType, IntegerType, valueContainsNull = true), nullable = true) )
      ), shardingColumns = Array("id"), pkColumns = Array("id"))

    var resDrop = ctx.dropTable(tabSchema.tableName)
    assert(resDrop.isEmpty, s"drop table: ${resDrop.getOrElse("success")}")

    var res = ctx.createTable(tabSchema)
    assert(res.isEmpty, s"create table: ${res.getOrElse("success")}")

    //insert into the table
    val tab = ctx.getTable(tabName)
    println("Table schema = " + tab )
    val rows = Seq(Row(7,"eleven", Seq[Int](1,2,3), Map(1->1,2->2)),
     	   	   Row(8,"twelve", Seq[Int](3,4), Map(100->9)) )

    for( row <- rows ){ 
        println( s"Inserting single row: ")// + row)
    	val res1 = ctx.insert(tab, row)
    	if (res1.failed)
	      	println(s"single row insert failed: $res1")
    	else
      		println(s"Row successfully inserted into $tabName")
    }

    // Make the table for the streams example
    val MLtabName = "IOT_TEMP"

    println("Creating table " + MLtabName)
    val MLtabSchema = TableSchema(MLtabName, StructType(Array(
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

    val MLindexSchema = IndexSpecification(
         indexName=MLtabName + "Index",
         tableSchema=tabSchema,
         equalColumns = Array("deviceID", "sensorID"),
         sortColumns = Array(
           SortSpecification("ts", ColumnOrder.DescendingNullsLast)),
         includeColumns = Array("temperature")
    )

    var MLresDrop = ctx.dropTable(MLtabSchema.tableName)
    assert(MLresDrop.isEmpty, s"drop table: ${MLresDrop.getOrElse("success")}")

    var MLres = ctx.createTableWithIndex(MLtabSchema,MLindexSchema)
    assert(MLres.isEmpty, s"create table: ${MLres.getOrElse("success")}")

    EventContext.cleanUp()

    val sc = new SparkContext(new SparkConf().setAppName("ExampleScalaApp").setMaster(
        Option(System.getenv("MASTER")).getOrElse("local[3]")))
    try {
      val sqlContext = new EventSession(sc, dbName)
      sqlContext.openDatabase()
      sqlContext.setQueryReadOption("SnapshotNone")
   
      val ads = sqlContext.loadEventTable(tabName)
      println(ads.schema)
      ads.createOrReplaceTempView(tabName)

      val results = sqlContext.sql(s"SELECT count(*) FROM $tabName")
      results.show(100)
      val results2 = sqlContext.sql(s"SELECT id, name, CAST(q1 as String), CAST(q2 as String)  FROM $tabName")
      results2.show(100)
    } catch {
      case e: Exception =>
        println("EXCEPTION: attempting to exit..." + e.getMessage)
        e.printStackTrace()
        sys.exit(1)
    }
    sys.exit()
  }
}
