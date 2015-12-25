# Workbox
This the sample workbox for development based on vagrant and puppet (puppet apply provisioner).

## Preparations
To launch the project you'll need several packages to be installed on your system:
* The Vagrant by it self (https://docs.vagrantup.com/v2/installation/);
* The VirtualBox (the provider) (https://www.virtualbox.org/wiki/Downloads);
* Nfsd service (for the shared folders). It is highly recommended to use the ntp daemon too;
* Add the debian/jessie64 box by running `vagrant box add debian/jessie64`;

## Configuration
One more step to configure the vagrant box:
1. Download the proper version of the VBoxGuestAdditions.iso image and put it to the `/opt/virtualbox/` directory;
2. Open the Vagrantfile in your favorite editor. Go to the bottom of the config and
select proper manifest files you whant to use within your project;

## Installation
The installation is very simple:
1. Just clone the repo: `git clone git@github.com:zinovyev/workbox`;
2. Switch to the directory: `cd workbox`;
3. Run simple command to build and launch the box: `vagrant up`;
4. That's it! The box is up and running. Type `vagrant ssh` to ssh to the system.
5. Use folder called `shared` on your host to work with files on the guest virtual machine (the path will be `/vagrant`).