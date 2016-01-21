# modules/nginx/manifests/init.pp

class nginx (
    $version = '1.8.0',
    $pid_file = '/usr/local/nginx/logs/nginx.pid'
) {

  include base, openssl

  # Define variables
  $worker_processes = $processorcount * 2;

  # Create www group
  group { 'www':
    ensure => 'present',
  }

  # Create www user
  user { 'www':
    ensure => 'present',
    groups => 'www',
  }

  # Install additional libraries
  package { ['libpcre3', 'libpcre3-dev', 'zlib1g', 'zlib1g-dev']:
      ensure => installed,
  }

  #
  # -- Compile and install nginx from source
  #

  if $nginx_installed == false {

      # Download nginx sources
      exec { 'download_nginx':
        cwd => '/tmp',
        command => "wget http://nginx.org/download/nginx-$version.tar.gz",
        creates => "/tmp/nginx-$version.tar.gz",
      }

      # Extract archive
      exec { 'extract_nginx':
        cwd => '/tmp',
        command => "tar xvzf  nginx-$version.tar.gz",
        require => Exec['download_nginx'],
      }

      # Get pcre sources
      exec {'pcre_lib_sources':
        cwd => "/tmp/nginx-$version",
        command => "apt-get source libpcre3 && mv pcre3-* pcre3",
        onlyif => ['test ! -d pcre3'],
        require => Exec['extract_nginx'],
      }

      # Get zlib1g source
      exec {'zlib1g_lib_sources':
        cwd => "/tmp/nginx-$version",
        command => "apt-get source zlib1g && mv zlib-* zlib",
        onlyif => ['test ! -d zlib'],
        require => Exec['extract_nginx'],
      }

      # Configure
      exec { 'configure_nginx':
        cwd => "/tmp/nginx-$version",
        command => "sh -c './configure \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --user=www \
        --group=www \
  #      --pid-path=/tmp/nginx.pid \
  #      --error-log-path=/var/log/nginx/error.log \
  #      --http-log-path=/var/log/nginx/access.log \
        --with-http_ssl_module \
        --with-pcre=pcre3 \
        --with-pcre-jit \
        --with-zlib=zlib'",
        require => [
            Exec['extract_nginx'],
            Exec['pcre_lib_sources'],
            Exec['zlib1g_lib_sources'],
          ],
      }

      # Make
      exec { 'make_nginx':
        cwd => "/tmp/nginx-$version",
        command => 'make -j`nproc`',
        require => Exec['configure_nginx'],
      }

      # Install
      exec { 'install_nginx':
        cwd => "/tmp/nginx-$version",
        command => 'make install',
        require => Exec['make_nginx'],
      }

  }

  #
  # -- Configure nginx
  #

    # Nginx main config
  file { '/etc/nginx/nginx.conf':
    ensure  => file,
    content => template('nginx/nginx.conf.erb'),
  }

    # Create a directory for available sites
  file { '/etc/nginx/sites-available':
    ensure => 'directory',
  }

    # Create a directory for enabled sites
  file { '/etc/nginx/sites-enabled':
    ensure => 'directory',
  }

    # Create the default config
  file { '/etc/nginx/sites-available/default.conf':
    ensure => 'file',
    source => 'puppet:///modules/nginx/default.conf',
    require => File['/etc/nginx/sites-available']
  }

    # preferred symlink syntax
  file { '/etc/nginx/sites-enabled/default.conf':
    ensure => 'link',
    target => '/etc/nginx/sites-available/default.conf',
    require => [
      File['/etc/nginx/sites-available/default.conf'],
      File['/etc/nginx/sites-enabled'],
    ],
    notify => Service['nginx.service'],
  }

  #
  # -- Set up nginx service
  #

  # Create nginx pid file
  file { 'nginx.pid':
    path => $pid_file,
    ensure  => 'file',
    content => "",
  }

  # Systemd file as /lib/systemd/system/nginx.service
  file { 'nginx.service':
    path => '/lib/systemd/system/nginx.service',
    ensure => 'file',
    content => template('nginx/nginx.service.erb'),
    require => File['nginx.pid'],
  }

  # Ensure the service is running
  service { 'nginx.service':
    enable => true,
    ensure => 'running',
    require => [
      File['/etc/nginx/nginx.conf'],
      File['nginx.pid'],
      File['nginx.service'],
    ]
  }

}