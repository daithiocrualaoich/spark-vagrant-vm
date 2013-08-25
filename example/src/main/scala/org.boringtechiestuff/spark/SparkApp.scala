package org.boringtechiestuff.spark

import spark.SparkContext

abstract class SparkApp extends App {

  val name = getClass.getName

  val local = args.toList contains ("--local")
  private val arguments = args.toList filter { _ != "--local" }

  lazy val input = arguments(0)
  lazy val output = arguments(1)

  val (master, install, library) = local match {
    case true => ("local", "", "target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar")
    case false => (
      "spark://localhost:7077",
      "/opt/spark-0.7.3",
      "hdfs://localhost:9000/lib/spark-assembly-1-SNAPSHOT.jar")
  }

  lazy val context = new SparkContext(master, name, install, Seq(library))
}
