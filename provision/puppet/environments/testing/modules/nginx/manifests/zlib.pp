# modules/nginx/manifests/zlib_source.pp

class nginx::zlib_source {
  # Install additional libraries
  $zlib_package = ['zlib1g', 'zlib1g-dev']
  package { $zlib_package:
    ensure => installed,
  }

  # Get zlib1g source
  exec {'get_zlib_source':
    cwd => "/tmp",
    command => "apt-get source zlib1g && mv zlib-* zlib_source",
    require => Package[$zlib_package],
    onlyif => ['test ! -d zlib_source'],
  }
}