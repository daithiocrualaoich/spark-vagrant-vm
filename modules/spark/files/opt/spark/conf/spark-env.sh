export SCALA_HOME=/opt/scala-2.9.3

export SPARK_MASTER_IP=localhost
export MASTER=spark://localhost:7077

export SPARK_LIBRARY_PATH=/usr/lib/native/Linux-amd64-64
export SPARK_JAVA_OPTS="-verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dspark.local.dir=/tmp/spark"

export SPARK_MEM="1g"

