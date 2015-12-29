# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version ">= 1.7.0"

# Check for missing plugins
required_plugins = %w(vagrant-vbguest)
required_plugins.each do |plugin|
  unless Vagrant.has_plugin?(plugin)
    system "vagrant plugin install #{plugin}"
  end
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|

  # Greetings message
  config.vm.post_up_message = <<MESSAGE
    This configuration uses the NFS for synced folders.

    Before using synced folders backed by NFS,
    the host machine must have nfsd installed,
    the NFS server daemon.
    This comes pre-installed on Mac OS X,
    and is typically a simple package install on Linux.
MESSAGE

  # The full path or URL to the VBoxGuestAdditions.iso file (should be downloaded manually).
  # The additions iso can be downloaded from the url (replace '%{version}' with your version number):
  # http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso
  config.vbguest.iso_path = "/opt/virtualbox/VBoxGuestAdditions_%{version}.iso"

  # Update VirtualBox Guest additions
  config.vbguest.auto_update = true

  # do NOT download the iso file from a webserver
  config.vbguest.no_remote = true

  # Configure virtualbox specific settings
  config.vm.provider "virtualbox" do |vb|
    vb.name = "workbox"
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
  config.vm.synced_folder "shared", "/vagrant", type: "nfs"

  # Preinstall Puppet via the shell provisioning
  config.vm.provision "shell" do |shell|
    shell.inline = <<-SHELL
      if [[ 0 != `which puppet > /dev/null && echo $?` ]]; then
        wget http://apt.puppetlabs.com/puppetlabs-release-pc1-jessie.deb && mv puppetlabs-release-pc1-jessie.deb /tmp
        dpkg -i /tmp/puppetlabs-release-pc1-jessie.deb
        apt-get update -y
        apt-get install -y puppetserver
        if [ ! -d /opt/puppetlabs/bin/ ]; then
          echo "Failed to install puppet. Directory '/opt/puppetlabs/bin/puppet' does not exist!"; exit 1
        fi
      fi
    SHELL
  end

  # Enable provisioning with Puppet.
  config.vm.provision "puppet" do |puppet|
     # Used to determinate that Puppet version installed on guest is >=4.0
    puppet.environment_path = "provision/puppet/environments"
    puppet.environment = "testing"

    # Puppet options
    puppet.binary_path = "/opt/puppetlabs/bin"
    puppet.module_path = "provision/puppet/environments/testing/modules"
    puppet.manifests_path = "provision/puppet/environments/testing/manifests"
    puppet.manifest_file = "init.pp"
    puppet.synced_folder_type = "nfs"
  end
end