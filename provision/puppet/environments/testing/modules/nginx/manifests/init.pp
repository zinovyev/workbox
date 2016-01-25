# modules/nginx/manifests/init.pp

class nginx (
  $version = '1.8.0',
  $owner = 'www',
  $group = 'www',
  $pid_dir = '/var/log/nginx',
  $log_dir = '/var/log/nginx',
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
  $pid_file = "${pid_dir}/nginx.pid"
  $error_log = "${log_dir}/error.log"
  $access_log = "${log_dir}/access.log"

  # Create pid file
  exec { 'nginx_pid_dir':
    creates => $pid_dir,
    command => "mkdir -p ${pid_dir}",
    onlyif  => "test ! -e ${pid_dir}",
  }
  file { 'nginx_pid_file':
    path    => $pid_file,
    ensure  => 'file',
    content => "",
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Exec['nginx_pid_dir']
  }

  # Create error log file
  exec { 'nginx_log_dir':
    creates => $log_dir,
    command => "mkdir -p ${log_dir}",
    onlyif  => "test ! -e ${log_dir}",
  }
  file { 'nginx_error_log':
    path    => $error_log,
    ensure  => 'file',
    content => "",
    owner   => $owner,
    group   => $group,
    mode    => '0664',
    require => Exec['nginx_log_dir']
  }

  # Create access log file
  file { 'nginx_access_log':
    path    => $access_log,
    ensure  => 'file',
    content => "",
    owner   => $owner,
    group   => $group,
    mode    => '0664',
    require => Exec['nginx_log_dir']
  }

  # Compile and install nginx
  if $is_nginx_installed == false {

    # Download nginx sources
    exec { 'download_nginx':
      cwd     => '/tmp',
      command => "wget http://nginx.org/download/nginx-${version}.tar.gz",
      creates => "/tmp/nginx-${version}.tar.gz",
    }

    # Extract archive
    exec { 'extract_nginx':
      cwd     => '/tmp',
      command => "tar xvzf nginx-${version}.tar.gz",
      require => Exec['download_nginx'],
      creates => "/tmp/nginx-${version}",
    }

    # Prepare nginx configure command
    $nginx_configure_command = "sh -c './configure \
        --sbin-path=/usr/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --user=${owner} \
        --group=${group} \
        --pid-path=${pid_file} \
        --error-log-path=${error_log} \
        --http-log-path=${access_log}'"

    exec { 'configure_nginx':
      cwd     => "/tmp/nginx-${version}",
      command => $nginx_configure_command,
      require => [
        Exec['extract_nginx'],
        File['nginx_error_log'],
        File['nginx_access_log'],
        File['nginx_pid_file']
      ],
    }

    # Make
    exec { 'make_nginx':
      cwd     => "/tmp/nginx-${version}",
      command => 'make -j`nproc`',
      require => Exec['configure_nginx'],
    }

    # Install
    exec { 'install_nginx':
      cwd     => "/tmp/nginx-${version}",
      command => 'make install',
      require => Exec['make_nginx'],
    }
  }

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
    ensure  => 'file',
    source  => 'puppet:///modules/nginx/default.conf',
    require => File['/etc/nginx/sites-available']
  }

  # Enable default site
  file { '/etc/nginx/sites-enabled/default.conf':
    ensure  => 'link',
    target  => '/etc/nginx/sites-available/default.conf',
    require => [
      File['/etc/nginx/sites-available/default.conf'],
      File['/etc/nginx/sites-enabled'],
    ],
    notify  => Service['nginx.service'],
  }

  # Systemd file as /lib/systemd/system/nginx.service
  file { 'nginx_service_file':
    path    => '/lib/systemd/system/nginx.service',
    ensure  => 'file',
    content => template('nginx/nginx.service.erb'),
    require => File['nginx_pid_file'],
  }

  # Ensure the service is running
  service { 'nginx.service':
    enable  => true,
    ensure  => 'running',
    require => [
      File['/etc/nginx/nginx.conf'],
      File['nginx_pid_file'],
      File['nginx_service_file'],
    ]
  }
}