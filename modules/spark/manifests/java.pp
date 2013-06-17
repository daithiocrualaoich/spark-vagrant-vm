class spark::java {

  require base

  package {
    'openjdk-6-jdk': ensure => latest;
  }
}
