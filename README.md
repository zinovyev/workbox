# Workbox
This the sample workbox for development based on vagrant and puppet (puppet apply provisioner).

## About
This box provides a bunch of puppet modules that I use by myself in my projects. It's not fully complete yet.
In production the modules should be installed via the puppet master node used together with child nodes.
The list of already built modules:
* [toolbox](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/toolbox): provides base packages (some of them are used for building other packages)
* [mariadb](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/mariadb): MariaDB package installation
* [nginx](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/nginx): compiles Nginx server from sources
* [nginx_ssl](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/nginx): exanple of an nginx config with self-signed certificate on board
* [openssl](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/openssl): OpenSSL packages installation
* [ss_ssl](https://github.com/zinovyev/workbox/tree/master/provision/puppet/environments/testing/modules/ss_ssl): generation of an self-signed certificate

## Preparations
To launch the project you'll need several packages to be installed on your system:
* The Vagrant by it self (https://docs.vagrantup.com/v2/installation/);
* The VirtualBox (the provider) (https://www.virtualbox.org/wiki/Downloads);
* Nfsd service (for the shared folders). It is highly recommended to use the ntp daemon too;
* Add the debian/jessie64 box by running `vagrant box add debian/jessie64`;

## Configuration
One more step to configure the vagrant box:

1. Download the proper version of the VBoxGuestAdditions.iso image and put it to the `/opt/virtualbox/` directory;
2. Open `/path-to-workbox/provision/puppet/environments/testing/manifests/init.pp` in your favorite editor and select modules you whant to use.

## Installation
The installation is very simple:

1. Just clone the repo: `git clone git@github.com:zinovyev/workbox`;
2. Switch to the directory: `cd workbox`;
3. Run simple command to build and launch the box: `vagrant up`;
4. That's it! The box is up and running. Type `vagrant ssh` to ssh to the system.
5. Use folder called `shared` on your host to work with files on the guest virtual machine (the path will be `/vagrant`).

## Testing your environment
To test the modules locally (no need to run `vagrant reload --provision`):

1. Add path to the puppet executable to your root's pathes:
```bash
sudo su
echo "export PATH=$PATH:/opt/puppetlabs/bin" >> ~/.bashrc
```

2. Reload root's profile config:
```bash
source ~/.bashrc
```

3. And run `puppet apply` command with specific options:
```bash
puppet apply /tmp/vagrant-puppet/environments/testing/manifests/init.pp \
--modulepath /tmp/vagrant-puppet/environments/testing/modules \
--verbose
```

## Troubleshooting
### NFS shared folders error
If you're stacked with the issue when `vagrant up` command hangs with the message "Mounting NFS shared folders..." for a while, try to perform those steps:
* Try either to restart nfs service (`sudo systemctl restart nfs-server.service` for me in Arch);
* Or to remove Vagrant entries from /etc/exports
(they are surrounded with #VAGRANT-BEGIN: ... #VAGRANT-END: comments)
and then to restart the service and the vagrant instance (run `vagrant reload` from your projects folder).