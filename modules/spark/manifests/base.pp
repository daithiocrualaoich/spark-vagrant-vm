class spark::base {
  exec {
    'apt-update':
      command => '/usr/bin/apt-get update';
  }

  package {
    [
      'bash-completion',
      'vim',
      'curl',
      'unzip'
    ]: ensure => latest;
  }

  Exec['apt-update'] -> Package <| |>
}
