class spark::scala {

  require base
  require java

  $version = '2.9.3'

  $url = 'http://www.scala-lang.org/downloads/distrib/files'
  $filename = "scala-${version}.tgz"
  $extracted = "scala-${version}"

  exec {
    'download-scala':
      command => "/usr/bin/wget ${url}/${filename}",
      cwd     => '/root',
      creates => "/root/${filename}",
      timeout => 0;

    'extract-scala':
      command => "/bin/tar xzf /root/${filename}",
      cwd     => '/opt',
      creates => "/opt/${extracted}",
      timeout => 0;
  }

  Exec['download-scala'] -> Exec['extract-scala']
}