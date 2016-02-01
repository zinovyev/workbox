# -*- mode: ruby -*-
# vi: set ft=ruby :
# php5_installed.rb

require 'facter'

Facter.add("is_php5_installed") do
  setcode do
    Dir.exists?('/usr/local/php5')
  end
end