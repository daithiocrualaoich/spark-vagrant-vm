package org.boringtechiestuff.spark

import spark.streaming.{ DStream, Seconds, StreamingContext }

abstract class StreamingSparkApp extends SparkApp {

  // Clean up old metadata after an hour
  System.setProperty("spark.cleaner.ttl", "3600")

  val batchDurationSeconds: Long

  lazy val streamingContext = new StreamingContext(context, Seconds(batchDurationSeconds))

  implicit def dStream2Collect[T: ClassManifest](stream: DStream[T]) = new {
    def collect[U: ClassManifest](f: PartialFunction[T, U]): DStream[U] = {
      stream.filter(f.isDefinedAt).map(f)
    }
  }
}
