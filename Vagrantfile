# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "freebsd/FreeBSD-10.2-STABLE"

  # The time in seconds that Vagrant will wait for the machine to boot and be accessible.
  # By default this is 300 seconds.
  config.vm.boot_timeout = 600

  # The guest OS that will be running within this machine
  config.vm.guest = :freebsd

  # The hostname the machine should have
  config.vm.hostname = "workbox.loc"

  # Configure the MAC address
  config.vm.base_mac = "080028BF32C5"

  # Preferred provider
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.name = "workbox.loc"
    vb.memory = 2024
    vb.cpus = 2
    vb.customize ["modifymedium", "workbox.loc", "--resize", "25600"]
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network", 

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
end
