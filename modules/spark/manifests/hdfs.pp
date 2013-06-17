class spark::hdfs {

  require base
  require java

  # Match HDFS version numbers from AWS Elastic MapReduce
  $url ='http://archive.apache.org/dist/hadoop/common/hadoop-1.0.3'
  $filename ='hadoop_1.0.3-1_x86_64.deb'

  exec {
    'download-hadoop':
      command => "/usr/bin/wget ${url}/${filename}",
      cwd     => '/root',
      creates => "/root/${filename}",
      timeout => 0;
  }

  package {
    'hadoop':
      ensure   => installed,
      provider => dpkg,
      source   => "/root/${filename}";
  }

  file {
    '/root/hdfs-prestart.setup':
      source => 'puppet:///modules/spark/root/hdfs-prestart.setup',
      owner  => root,
      group  => root,
      mode   => '0744';

    '/root/hdfs-poststart.setup':
      source => 'puppet:///modules/spark/root/hdfs-poststart.setup',
      owner  => root,
      group  => root,
      mode   => '0744';

    '/etc/hadoop/hadoop-env.sh':
      source => 'puppet:///modules/spark/etc/hadoop/hadoop-env.sh',
      owner  => root,
      group  => root,
      mode   => '0644';

    '/etc/hadoop/core-site.xml':
      source => 'puppet:///modules/spark/etc/hadoop/core-site.xml',
      owner  => root,
      group  => root,
      mode   => '0644';

    '/etc/hadoop/hdfs-site.xml':
      source => 'puppet:///modules/spark/etc/hadoop/hdfs-site.xml',
      owner  => root,
      group  => root,
      mode   => '0644';
  }

  exec {
    'setup-hdfs-prestart':
      cwd       => '/root',
      command   => '/root/hdfs-prestart.setup',
      creates   => '/root/hdfs-prestart.done',
      logoutput => true;

    'setup-hdfs-poststart':
      cwd       => '/root',
      command   => '/root/hdfs-poststart.setup',
      creates   => '/root/hdfs-poststart.done',
      logoutput => true;
  }

  service {
    'hadoop-namenode':
      ensure => running,
      enable => true;

    'hadoop-datanode':
      ensure => running,
      enable => true;
  }

  Package[hadoop] -> File['/etc/hadoop/hadoop-env.sh'] -> Service['hadoop-namenode']
  Package[hadoop] -> File['/etc/hadoop/core-site.xml'] -> Service['hadoop-namenode']
  Package[hadoop] -> File['/etc/hadoop/hdfs-site.xml'] -> Service['hadoop-namenode']

  File['/root/hdfs-prestart.setup'] -> Exec['setup-hdfs-prestart']
  File['/root/hdfs-poststart.setup'] -> Exec['setup-hdfs-poststart']

  Exec['download-hadoop'] ->
    Package['hadoop'] ->
    Exec['setup-hdfs-prestart'] ->
    Service['hadoop-namenode'] ->
    Service['hadoop-datanode'] ->
    Exec['setup-hdfs-poststart']
}
