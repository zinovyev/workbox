# modules/toolbox/manifests/init.pp

class toolbox {

  # Base system packages
  $base_packages = [
    'coreutils',
    'sudo',
    'ntp',
    'wget',
    'curl',
    'vim',
    'git',
  ]
  package { $base_packages:
    ensure => installed,
  }

  # Enable ntp service (to make nfs work well)
  service { 'ntp':
    name   => 'ntp',
    ensure => running,
    enable => true,
  }

  # Packages required for building tools
  $build_packages = [
    'build-essential',
    'automake',
    'autoconf',
    'gcc',
    'clang',
    'make',
  ]
  package { $build_packages:
    ensure => installed
  }
}