package org.boringtechiestuff.spark

import spark.streaming.DStream
import spark.streaming.StreamingContext._
import org.json4s._
import org.json4s.native.JsonMethods._
import org.boringtechiestuff.common.Strings

object StreamingTweetWordCount extends StreamingSparkApp with Strings {

  val batchDurationSeconds = 10L

  val lines = streamingContext.textFileStream(input).cache()

  val jsons: DStream[JValue] = lines map { parse(_) }
  val texts: DStream[String] = jsons map { _ \ "text" } collect {
    case JString(text) => text
  }

  val tokens = texts flatMap { _.toLowercaseAlphabeticTokens }
  val tokenCounts = tokens map { token => (token, 1) }
  val counts = tokenCounts reduceByKey { _ + _ }

  counts.saveAsTextFiles(output + "/words")

  streamingContext.start()
}
