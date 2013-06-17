// Additional information on initialization
logLevel := Level.Warn

resolvers ++= Seq(
  "Typesafe repository" at "http://repo.typesafe.com/typesafe/releases/",
  "mpeltonen.github.com" at "http://mpeltonen.github.com/maven/"
)

addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "0.9.0")

addSbtPlugin("com.typesafe.sbtscalariform" % "sbtscalariform" % "0.5.1")

addSbtPlugin("com.github.mpeltonen" % "sbt-idea" % "1.4.0")