Spark Vagrant VM
================

Vagrant VM box for Spark.


Preliminaries: VirtualBox and Vagrant
-------------------------------------
[Vagrant][vagrant] is a tool to "create and configure lightweight, reproducible,
and portable development environments." Vagrant itself is a virtual instance
creation and startup tool on top of Oracle VirtualBox which takes care of the
virtualisation.

Download and install the Open Source Edition of VirtualBox from [virtualbox].

Then download and install Vagrant from [vagrant]. The Linux packages install
the `vagrant` executable at `/opt/vagrant/bin` and you will need to add this to
your path.


Building the VM
---------------
There is a `Rakefile` with useful targets for creating and generating the Spark
Vagrant VM. To create a new VM run the default Rake target:

    rake

This will create the Spark box in Vagrant and run the necessary Puppet
provisioning. This step will take some time to install Java, Hadoop, download
and compile Spark, etc.

When the box is complete, you will find it in `target`.

You will likely only need to do this once unless you want to adapt the VM and
make it available to others. If you are the trusting type, there is a prebuilt
VM at:

    https://dl.dropboxusercontent.com/u/1577066/vagrants/spark.box

Copy the download to the `target` directory if you are cheating and continue.

You can test the VM by using the Vagrant definition in `example`.

    cd example
    vagrant up
    vagrant ssh

The Spark Web UI will be port forwarded to port 8080 on your host so you can
open `http://localhost:8080` on your host computer to see some Spark details.

The HDFS Web UI is also port forwarded to port 50070 and 50075 so you can browse
the HDFS on the VM by opening `http://localhost:50070` on your host.

When finished, you destroy the VM using:

    vagrant destroy


Note for the Paranoid
---------------------
If you are inclined to paranoia, see `modules\spark\manifests\ssh.pp` for notes
on changing the passwordless root SSH needed on the VM instance to start a
Spark slave.


Note on the Versions
--------------------
The VM uses Spark 0.7.3 and Hadoop 1.0.3. The reason for the slightly peculiar
Hadoop is to match the version in Elastic MapReduce which this work originally
targetted.

A more recent Hadoop 1 can be selected by changing the download in
`/modules/spark/manifests/hdfs.pp`,updating the `sed`
substitution in `/modules/spark/templates/root/spark.setup.erb` and rebuilding.

To use the examples, you may also need to update the dependencies in
`/example/project/Spark.scala`.


Examples
--------
To run some sample applications, cd to `examples` and compile a fat jar from
the SBT project there:

    cd examples
    ./sbt012 assembly

The jar can be run on your host machine directly using e.g.:

    java -cp target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar \
      org.boringtechiestuff.spark.TweetWordCount \
      --local \
      dev/sample.json output

To run it on the VM, first SSH to it and put the necessary in HDFS:

    vagrant ssh

    hadoop fs -mkdir /lib
    hadoop fs -put /vagrant/target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar /lib

    hadoop fs -mkdir /input
    hadoop fs -put /vagrant/dev/sample.json /input

The `/vagrant` directory is a convenience mount of the `examples` directory onto
the VM.

Run the same application as earlier but in cluster mode this time:

    java -cp /vagrant/target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar \
        org.boringtechiestuff.spark.TweetWordCount \
        hdfs://localhost:9000/input \
        hdfs://localhost:9000/output

Check the Web UI on `localhost:8080` to prove it is doing something. When done,
the output can be checked using:

    hadoop fs -ls /output
    hadoop fs -text /output/part-*


Streaming Examples
------------------
Spark also provides a streaming mode.

A streaming version of the previous can be run on your host machine directly
using:

    java -cp target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar \
      org.boringtechiestuff.spark.StreamingTweetWordCount \
      --local \
      input output

In this case new files added in `input` will be picked up and processed and
result left in `output` by timestamp. For instance, copy the input file:

    mkdir input
    cp dev/sample.json input

After a few seconds, a new directory will be added in output with the results:

   cd output
   ls -alR

And look for the directory with a nonzero `part-00000`.

The application runs until explicitly killed.

As before, this works on the VM also:

    vagrant ssh

    hadoop fs -rmr /input
    hadoop fs -mkdir /input
    hadoop fs -rmr /output

    java -cp /vagrant/target/scala-2.9.3/spark-assembly-1-SNAPSHOT.jar \
            org.boringtechiestuff.spark.StreamingTweetWordCount \
            hdfs://localhost:9000/input \
            hdfs://localhost:9000/output

In another console:

    vagrant ssh

    hadoop fs -put /vagrant/dev/sample.json /input/sample2.json

    hadoop fs -lsr /output

And look for the nonempty `part` files again.


Vagrant Commmands
-----------------
Some useful Vagrant commands.

* `vagrant suspend`: Disable the virtual instance. The allocated disc space
  for the instance is retained but the instance will not be available. The
  running state at suspend time is saved for resumption.
* `vagrant resume`: Wake up a previously suspended virtual instance.
* `vagrant halt`: Turn off the virtual instance. Calling `vagrant up` after
  this is the equivalent of a reboot.
* `vagrant destroy`: Hose your virtual instance, reclaiming the allocated disc
  space.
* `vagrant provision`: Rerun puppet or chef provisioning on the virtual
  instance.
* `vagrant box list`: List the VM definitions that Vagrant has imported.
* `vagrant box remove <name>`: Remove the named VM definition from Vagrant,
  possibly to allow for an updated version to be imported.


Vagrant SSH X Forwarding
------------------------
X applications on VMs can be displayed on the host machine by specifying a
Vagrant SSH connection with X11 forwarding in the `Vagrantfile`:

    config.ssh.forward_x11 = true

On the host machine, add an `xhost` for the Vagrant VM:

    xhost +10.0.0.2

Then X applications started from the VM should display on the host machine.


Vagrant Troubleshooting
-----------------------
To see more verbose output on any vagrant command, add a VAGRANT_LOG environment
variable setting, e.g.:

    VAGRANT_LOG=INFO /opt/vagrant/bin/vagrant up

Further help troubleshooting can be obtained by editing your `Vagrantfile` and
enabling the `config.vm.boot_mode = :gui` setting. This will pop up a VirtualBox
GUI window on boot.


[virtualbox]: https://www.virtualbox.org/wiki/Downloads
[vagrant]: http://vagrantup.com
