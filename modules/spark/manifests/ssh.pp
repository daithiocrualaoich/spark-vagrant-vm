class spark::ssh {

  # Need passwordless SSH for root@localhost on VM to start Spark workers.

  # If you are paranoid, ssh-keygen a new key pair and copy it to
  # files/root/ssh. You will need to arrange a new authorized_keys with your
  # new key identifier, i.e. an exact copy of your new id_rsa.pub file is fine.

  file {
    '/root/.ssh':
      ensure => directory,
      owner  => root,
      group  => root,
      mode   => '0555';

    '/root/.ssh/authorized_keys':
      source => 'puppet:///modules/spark/root/ssh/authorized_keys',
      owner  => root,
      group  => root,
      mode   => '0400';

    '/root/.ssh/id_rsa':
      source => 'puppet:///modules/spark/root/ssh/id_rsa',
      owner  => root,
      group  => root,
      mode   => '0400';

    '/root/.ssh/id_rsa.pub':
      source => 'puppet:///modules/spark/root/ssh/id_rsa.pub',
      owner  => root,
      group  => root,
      mode   => '0400';
  }
}
