# modules/nginx/manifests/init.pp

class nginx (
    $version = '1.8.0',
    $owner = 'www',
    $group = 'www',
    $pid_file_dir = '/var/log/nginx/nginx.pid',
    $error_log_dir = '/var/log/nginx/',
    $access_log_dir = '/var/log/nginx/access.log',
    $with_ssl_module = true,
    $with_pcre3 = true,
    $with_zlib = true,
) {

  # include toolbox, openssl

  # Define variables
  $worker_processes = $processorcount * 2;

  # Create www group
  group { $group:
    ensure => 'present',
  }

  # Create www user
  user { $owner:
    ensure => 'present',
    groups => $group,
  }

    # File names
    $pid_file = "${pid_file_dir}/nginx.pid"
    $error_log = "${error_log_dir}/error.log"
    $access_log = "${access_log_dir}/access.log"

    # Precreate pid file dir and file
    file { $pid_file_dir:
        ensure => directory,
    }
    file { 'pid_file':
      path => $pid_file,
      ensure  => 'file',
      content => "",
      owner => 'root',
      group => 'root',
      mode => '0700',
    }

    # Precreate error log dir and file
    file { $error_log_dir:
        ensure => directory,
    }
    file { 'error_log':
      path => $error_log,
      ensure  => 'file',
      content => "",
      owner => $owner,
      group => $group,
      mode => '0664',
    }

    # Precreate access log dir and file
    file { $access_log_dir:
        ensure => directory,
    }
    file { 'access_log':
      path => $access_log,
      ensure  => 'file',
      content => "",
      owner => $owner,
      group => $group,
      mode => '0664',
    }

  # Compile and install nginx from source
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
        command => "tar xvzf nginx-$version.tar.gz",
        require => Exec['download_nginx'],
      }

      # Configure
      $nginx_configure_command = "sh -c './configure \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --user=$owner \
        --group=$group \
        --pid-path=$pid_file \
        --error-log-path=$error_log \
        --http-log-path=$access_log"

      # Enable ssl module
      if  with_ssl_module == true {
          $nginx_configure_command = $nginx_configure_command" \
            --with-http_ssl_module \
          "
      }

      # Enable pcre3 support
      if  with_pcre3 == true {
          $pcre3_source_dir = '/tmp/pcre3_source'
          class { "nginx::pcre3_source":
            path => $pcre3_source_dir,
          }
          $nginx_configure_command = $nginx_configure_command" \
            --with-pcre=$pcre3_source_dir \
            --with-pcre-jit \
          "
      }

      # Enable zlib support
      if  with_zlib == true {
          $zlib_source_dir = '/tmp/zlib_source'
          class { 'nginx::zlib_source':
            path = $zlib_source_dir
          }
          $nginx_configure_command = $nginx_configure_command" \
            --with-zlib=$zlib_source_dir
          "
      }

      exec { 'configure_nginx':
        cwd => "/tmp/nginx-$version",
        command => $nginx_configure_command,
        require => [
            Exec['extract_nginx'],
            # Exec['pcre_lib_sources'],
            # Exec['zlib1g_lib_sources'],
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

  # Systemd file as /lib/systemd/system/nginx.service
  file { 'nginx.service':
    path => '/lib/systemd/system/nginx.service',
    ensure => 'file',
    content => template('nginx/nginx.service.erb'),
    require => File['pid_file'],
  }

  # Ensure the service is running
  service { 'nginx.service':
    enable => true,
    ensure => 'running',
    require => [
      File['/etc/nginx/nginx.conf'],
      File['pid_file'],
      File['nginx.service'],
    ]
  }

}