import com.ibm.event.oltp.EventContext
import com.ibm.event.common.ConfigurationReader
import org.apache.spark.sql.ibm.event.EventSession
import com.ibm.event.catalog.TableSchema
import org.apache.spark.sql.types._
import org.apache.spark.sql.Row
import org.apache.spark.{SparkConf, SparkContext}

object RemoteClientTest {

  def main(args: Array[String]): Unit = {

    ConfigurationReader.setConnectionEndpoints("9.30.189.50:1101")

    println("Please specify name of the new DB: ")
    val dbName = scala.io.StdIn.readLine()

    try {
       println(s"Dropping database $dbName")
       EventContext.dropDatabase(dbName)
    } catch {
        case e: Exception =>
          println(s"error while dropping DB: ${e.getMessage}")
    }
    println(s"Creating database $dbName")
    val ctx = EventContext.createDatabase(dbName)

    val tabName = "tab1"

    println("Creating table " + tabName)
    val tabSchema = TableSchema(tabName, StructType(Array(
        StructField("id", IntegerType, false),
        StructField("name", StringType, false))
      ), shardingColumns = Array("id"), pkColumns = Array("id"))

    var res = ctx.createTable(tabSchema)
    assert(res.isEmpty, s"create table: ${res.getOrElse("success")}")

    //insert into the table
    val tab = ctx.getTable(tabName)
    val row = Row(7,"eleven")
    println( s"Inserting single row: " + row)

    val res1 = ctx.insert(tab, row)
    if (res1.failed)
      println(s"single row insert failed: $res1")
    else
      println(s"Row successfully inserted into $tabName")

    EventContext.cleanUp()

  }
}
