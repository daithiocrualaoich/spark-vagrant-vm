class spark::git {

  require base

  package {
    'git': ensure => latest;
  }
}
