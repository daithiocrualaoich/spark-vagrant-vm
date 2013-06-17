package org.boringtechiestuff.spark

import spark.RDD
import spark.SparkContext._
import org.json4s._
import org.json4s.native.JsonMethods._
import org.boringtechiestuff.common.Strings

object TweetWordCount extends SparkApp with Strings {

  val lines = context.textFile(input).cache()

  val jsons: RDD[JValue] = lines map { parse(_) }
  val texts: RDD[String] = jsons map { _ \ "text" } collect {
    case JString(text) => text
  }

  val tokens = texts flatMap { _.toLowercaseAlphabeticTokens }
  val tokenCounts = tokens map { token => (token, 1) }
  val counts = tokenCounts reduceByKey { _ + _ }

  counts.saveAsTextFile(output)
}
