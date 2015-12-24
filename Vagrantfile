# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.0"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  # Greetings message
  config.vm.post_up_message = <<-MESSAGE
    This configuration uses the NFS for synced folders.

    Before using synced folders backed by NFS,
    the host machine must have nfsd installed,
    the NFS server daemon.
    This comes pre-installed on Mac OS X,
    and is typically a simple package install on Linux.
  MESSAGE

  # Update VirtualBox Guest additions
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  # config.vbguest.no_remote = true
  #

  # Configure virtualbox specific settings
  config.vm.provider "virtualbox" do |vb|
    vb.name = "dev_workbox"
    vb.memory = 2048
    vb.cpus = 2
  end

  # Every Vagrant development environment requires a box.
  config.vm.box = "debian/jessie64"

  # Disable automatic box update checking. If you disable this, then
  config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine.
  config.vm.network "forwarded_port", guest: 80, host: 8040

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.50.4"

  # Share an additional folder to the guest VM.
  config.vm.synced_folder "./shared", "/vagrant", type: "nfs"

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL
end
