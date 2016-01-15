# modules/nginx/manifests/init.pp

class nginx (
    $version = '1.8.0'
) {

    include base, openssl

    # Create www group
    group { 'www':
      ensure => 'present',
    } ->

    # Create www user
    user { 'www':
      ensure => 'present',
      groups => 'www',
    } ->

    # Install additional libraries
    package { ['libpcre3', 'libpcre3-dev', 'zlib1g', 'zlib1g-dev']:
        ensure => installed,
    } ->

    # Check if nginx is installed
    exec { 'if_nginx_not_installed':
      command => '/bin/true',
      onlyif => 'test ! -f /lib/systemd/system/nginx.service'
    } ->

    # Download nginx sources
    exec { 'download':
      cwd => '/tmp',
      command => "wget http://nginx.org/download/nginx-$version.tar.gz",
      creates => "/tmp/nginx-$version.tar.gz",
    } ->

    # Extract archive
    exec { 'extract':
      cwd => '/tmp',
      command => "tar xvzf  nginx-$version.tar.gz",
    } ->

    # Get pcre sources
    exec {'pcre sources':
      cwd => "/tmp/nginx-$version",
      command => "apt-get source libpcre3 && mv pcre3-* pcre3"
    } ->

    # Get zlib1g source
    exec {'zlib1g sources':
      cwd => "/tmp/nginx-$version",
      command => "apt-get source zlib1g && mv zlib-* zlib"
    } ->

    # Configure
    exec { 'configure':
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
    } ->

    # Make
    exec { 'make':
      cwd => "/tmp/nginx-$version",
      command => 'make -j`nproc`',
    } ->

    # Install
    exec { 'install':
      cwd => "/tmp/nginx-$version",
      command => 'make install',
    } ->

    # Systemd file as /lib/systemd/system/nginx.service
    file { 'systemd':
      path => '/lib/systemd/system/nginx.service',
      ensure => 'file',
      source => 'puppet:///modules/nginx/nginx.service',
    } ->

    # Create pid file
#    file { 'pid_file':
#      path => '/usr/local/nginx/logs/nginx.pid',
#      ensure  => 'present',
#      replace => 'no',
#      content => "",
#    } ->

      # Install
    exec { 'pid_file':
      cwd => "/usr/local/nginx/logs/",
      command => 'touch nginx.pid',
    } ->

    # Ensure the service is running
    service { 'nginx.service':
      enable => true,
      ensure => 'running',
    }
}