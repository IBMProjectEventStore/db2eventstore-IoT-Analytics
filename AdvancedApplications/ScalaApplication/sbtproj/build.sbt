import scala.language.postfixOps // <- making IntelliJ hush about the ! bash command postfix

name := "Remotescala"
organization := "com.ibm"
version := "1.3.0-RELEASE"
//scalaVersion := "2.10.4"
scalaVersion := "2.11.8"
scalacOptions ++= Seq("-unchecked", "-deprecation", "-feature")
compileOrder in Compile := CompileOrder.ScalaThenJava

val circeVersion           = "0.3.0"
val jodaTimeVersion        = "2.9.4"
//val eventstoreDriverVersion = "2.1.10.2"
val junitVersion           = "4.10"
val log4jVersion           = "2.2"
val scalacheckVersion      = "1.11.4"
val scalatestVersion       = "2.2.2"
val scalazVersion          = "7.1.2"
val slf4jVersion           = "1.7.12"
//val curatorVersion         = "2.4.1"
//val curatorVersion         = "2.10.0"
val curatorVersion         = "2.11.0"
val zooKlientVersion       = "0.3.1-RELEASE"
//val sparkver = 		"2.1.0"
val sparkver = 		"2.0.2"

parallelExecution in Test := false

//resolvers ++= Seq(
//  "Artifactory" at "https://repo.artifacts.weather.com/analytics-virtual"
//)

libraryDependencies ++= Seq(
  "com.ibm.event" % "ibm-db2-eventstore-client" % "1.1.3",
  "com.google.protobuf" % "protobuf-java" % "2.5.0",
  "org.apache.spark" %% "spark-core" % sparkver intransitive(), 

  "org.apache.spark" %% "spark-unsafe" % sparkver intransitive(), 

  "org.apache.spark" %% "spark-catalyst" % sparkver intransitive(), 

  "org.apache.spark" %% "spark-sql" % sparkver  intransitive(), 

  "org.apache.spark" %% "spark-streaming" % sparkver % "provided",

  "org.apache.spark" %% "spark-hive" % sparkver % "provided",
  "org.apache.hadoop" % "hadoop-core" % "0.20.2" intransitive(),
  "com.esotericsoftware.kryo" % "kryo" % "2.16",
  "org.apache.commons" % "commons-lang3" % "3.3.2",
  "org.json4s" % "json4s-ast_2.11" % "3.2.10",
  "org.json4s" % "json4s-core_2.11" % "3.2.10",

  "org.apache.spark" %% "spark-streaming-kafka-0-10" % sparkver % "provided",

  "com.google.guava" % "guava" % "16.0.1", // % "provided", 

  //"org.apache.curator" % "apache-curator" % curatorVersion,
  "org.apache.curator" % "curator-client" % curatorVersion % "provided",
  "org.apache.curator" % "curator-recipes" % curatorVersion, // % "provided",

  "io.netty" % "netty-all" % "4.0.29.Final",

  "org.slf4j"                   % "slf4j-log4j12"              % slf4jVersion, // % "provided",

  //"com.datastax.cassandra"       % "cassandra-driver-core" % cassandraDriverVersion
    //classifier "shaded"
    //excludeAll(
    //ExclusionRule(organization = "io.netty"),
    //ExclusionRule(organization = "com.google.guava")
    //),
  //"com.ibm"                      % "streams.operator"      % streamsOperatorVersion,  //% "provided",
  "io.circe"                    %% "circe-core"            % circeVersion, //  % "provided",
  "io.circe"                    %% "circe-generic"         % circeVersion, // % "provided",
  "io.circe"                    %% "circe-jawn"            % circeVersion, // % "provided",
  "org.apache.curator"           % "curator-framework"     % curatorVersion,// % "provided",
  "org.scalaz"                  %% "scalaz-core"           % scalazVersion, // % "provided",
  "org.apache.logging.log4j"    % "log4j-api"              % log4jVersion, // % "provided",
  "org.slf4j"                   % "slf4j-api"              % slf4jVersion, // % "provided",
  "joda-time"                   % "joda-time"              % jodaTimeVersion, // % "provided",
  "junit"                       % "junit"                  % junitVersion            % "test",
  "org.scalacheck"              %% "scalacheck"            % scalacheckVersion       % "test",
  "org.scalatest"               %% "scalatest"             % scalatestVersion        % "test",
  "org.slf4j"                   % "slf4j-simple"           % slf4jVersion            % "test",
  "org.apache.curator"          % "curator-test"           % curatorVersion          % "test"
)

