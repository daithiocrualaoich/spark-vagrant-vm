import com.typesafe.sbtscalariform.ScalariformPlugin._
import sbt._
import sbt.Keys._
import sbtassembly.Plugin.AssemblyKeys._
import sbtassembly.Plugin.MergeStrategy

object Spark extends Build {

  val project_version = "1-SNAPSHOT"

  val spark = Project("spark", file("."))
    .settings(scalariformSettings: _*)
    .settings(sbtassembly.Plugin.assemblySettings: _*)
    .settings(net.virtualvoid.sbt.graph.Plugin.graphSettings: _*)
    .settings(
      version := "1-SNAPSHOT",
      scalaVersion := "2.9.3",

      organization := "org.boringtechiestuff",

      resolvers ++= Seq(
        "Akka" at "http://repo.typesafe.com/typesafe/releases",
        "Spray" at "http://repo.spray.io"
      ),

      libraryDependencies ++= Seq(
        // Match the version of Hadoop on Elastic MapReduce
        "org.apache.hadoop" % "hadoop-core" % "1.0.3" exclude("org.eclipse.jdt", "core"),

        // Spark: Drop the hadoop-core 1.0.4 dependency
        "org.spark-project" %% "spark-core" % "0.7.3" exclude("org.apache.hadoop", "hadoop-core") exclude("org.slf4j", "slf4j-log4j12"),
        "org.spark-project" %% "spark-bagel" % "0.7.3" exclude("org.apache.hadoop", "hadoop-core"),
        "org.spark-project" %% "spark-streaming" % "0.7.3" exclude("org.apache.hadoop", "hadoop-core") exclude("org.jboss.netty", "netty"),

        "org.json4s" %% "json4s-native" % "3.2.4",
        "ch.qos.logback" % "logback-classic" % "1.0.13"
      ),

      mergeStrategy in assembly <<= (mergeStrategy in assembly) { (current) =>
        {
          // Hack together some dependency nonsenses into a fatjar.
          case s: String if s.startsWith("javax/servlet") => MergeStrategy.first
          case s: String if s.startsWith("org/apache/jasper") => MergeStrategy.first
          case s: String if s.startsWith("org/apache/commons/beanutils") => MergeStrategy.first
          case s: String if s.startsWith("org/apache/commons/collections") => MergeStrategy.first
          case s: String if s.endsWith(".html") => MergeStrategy.discard

          case x => current(x)
        }
      }
  )
}
