# modules/php5/manifests/init.pp

class php5 (
  $version = '5.6.17',
  $owner = 'www',
  $group = 'www',
) {

  $php5_dependencies = [
    #    'systemd',
    #    'libsystemd-dev',
    'libxml2-dev',
    'libcurl4-openssl-dev',
    #    'libssl-dev',
  ]
  package { $php5_dependencies:
    ensure => installed,
  }

  if $is_php5_installed == false {

    # Get php5 source
    exec { 'get_php5_source':
      command => "curl http://php.net/distributions/php-${version}.tar.bz2 > php-${version}.tar.bz2",
      cwd     => '/tmp',
    }

    # Extract sources
    exec { 'extract_php5_source':
      command => "tar xjf php-${version}.tar.bz2",
      cwd     => '/tmp',
      require => Exec['get_php5_source'],
    }

    # Configure php5 options
    $php5_options = [
      '--prefix=/usr/local/php5',
      '--exec-prefix=/usr/local/php5',
      '--sysconfdir=/etc/php5',
      '--enable-fpm',
      "--with-fpm-user=${owner}",
      "--with-fpm-group=${group}",
      #      '--with-fpm-systemd',
      #      '--with-fpm-acl',
      #      '--with-openssl=/usr/include/openssl',
      #      '--with-system-ciphers',
      '--with-pcre-regex',
      '--with-zlib',
      '--enable-bcmath',
      '--with-curl',
      '--enable-exif',
      #      '--with-gd',
      #      '--enable-intl',
      #      '--with-ldap',
      '--enable-mbstring',
      #      '--with-mcrypt',
      '--with-mysql',
      '--enable-opcache',
      '--enable-pcntl',
      '--enable-soap',
      '--enable-sockets',
      '--enable-sysvmsg',
      '--enable-sysvsem',
      '--enable-sysvshm',
      '--enable-zip',
      '--enable-maintainer-zts',
      '--with-tsrm-pthreads',
    ]
    $php5_options_string = join($php5_options, " ")
    exec { 'php5_configure':
      command => "sh -c './configure ${php5_options_string}'",
      cwd     => "/tmp/php-${version}",
      require => [
        Package[$php5_dependencies],
        Class['openssl'],
        Exec['extract_php5_source']
      ],
    }

    # Make php5
    exec { 'php5_make':
      command => 'make',
      cwd     => "/tmp/php-${version}",
      require => [
        Exec['php5_configure']
      ],
    }

    exec { 'php5_install':
      command => 'make install',
      cwd     => "/tmp/php-${version}",
      require => [
        Exec['php5_make']
      ],
    }
  }

}