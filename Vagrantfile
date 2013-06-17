Vagrant::Config.run do |config|

  config.vm.host_name = "spark"
  config.vm.customize [ "modifyvm", :id, "--name", "spark", "--memory", "2048" ]

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # config.vm.boot_mode = :gui
  config.ssh.forward_x11 = true

  config.vm.provision :puppet, 
    :options => "--modulepath=/vagrant/modules" do |puppet|
    puppet.manifests_path = "."
    puppet.manifest_file = "site.pp"
  end

  config.vm.forward_port 8080, 8080
  config.vm.forward_port 8081, 8081
  config.vm.forward_port 50070, 50070
  config.vm.forward_port 50075, 50075

end
