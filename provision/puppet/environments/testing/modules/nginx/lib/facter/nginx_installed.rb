# -*- mode: ruby -*-
# vi: set ft=ruby :
# nginx_installed.rb

require 'facter'

Facter.add("nginx_installed") do
  setcode do
    File.exists?('/usr/sbin/nginx')
  end
end