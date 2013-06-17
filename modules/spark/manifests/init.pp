class spark {

  require base
  require hdfs
  require ssh

  # Elastic MapReduce gets you as far as here. But you still need Scala, a
  # compiled Spark distribution and some configuration.

  require scala
  require git

  $version = '0.7.2'

  $url ='http://spark-project.org/files'
  $filename ="spark-${version}-sources.tgz"
  $extracted = "spark-${version}"

  exec {
    'download-spark':
      command => "/usr/bin/wget ${url}/${filename}",
      cwd     => '/root',
      creates => "/root/${filename}",
      timeout => 0;

    'extract-spark':
      command => "/bin/tar xzf /root/${filename}",
      cwd     => '/opt',
      creates => "/opt/${extracted}",
      timeout => 0;
  }

  file {
    "/opt/${extracted}/conf/spark-env.sh":
      source => 'puppet:///modules/spark/opt/spark/conf/spark-env.sh',
      owner  => root,
      group  => root,
      mode   => '0644';

    # On Elastic MapReduce, the right move here is copy core-site.xml from the
    # existing Hadoop installation.
    "/opt/${extracted}/conf/core-site.xml":
      source => 'puppet:///modules/spark/opt/spark/conf/core-site.xml',
      owner  => root,
      group  => root,
      mode   => '0644';

    '/root/spark.setup':
      content => template('spark/root/spark.setup.erb'),
      owner   => root,
      group   => root,
      mode    => '0744';

    '/etc/init.d/spark':
      source => 'puppet:///modules/spark/etc/init.d/spark',
      owner  => root,
      group  => root,
      mode   => '0744';

    '/etc/init/spark.conf':
      content => template('spark/etc/init/spark.conf.erb'),
      owner  => root,
      group  => root,
      mode   => '0744';
  }

  exec {
    'setup-spark':
      cwd       => '/root',
      command   => '/root/spark.setup',
      creates   => '/root/spark.done',
      logoutput => true,
      timeout   => 0;
  }

  service {
    'spark':
      ensure   => running,
      enable   => true,
      provider => 'upstart';
  }

  Exec['extract-spark'] ->
    File["/opt/${extracted}/conf/spark-env.sh"] ->
    Exec['setup-spark']

  Exec['extract-spark'] ->
    File["/opt/${extracted}/conf/core-site.xml"] ->
    Exec['setup-spark']

  File['/root/spark.setup'] -> Exec['setup-spark']

  File['/etc/init.d/spark'] -> Service[spark]
  File['/etc/init/spark.conf'] -> Service[spark]

  Exec['download-spark'] ->
    Exec['extract-spark'] ->
    Exec['setup-spark'] ->
    Service[spark]
}
