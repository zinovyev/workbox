# modules/nginx/manifests/init.pp

class nginx (
    $version = '1.8.0'
) {

    include base, openssl

    # Create www group
    group { 'www':
      ensure => 'present',
    }->

    # Create www user
    user { 'www':
      ensure => 'present',
      groups => 'www',
    } ->

    # Install additional libraries
    package { ['libpcre3', 'libpcre3-dev', 'zlib1g', 'zlib1g-dev']:
        ensure => installed,
    } ->

    if $nginx_service_exists == false {
      # Download nginx sources
      exec { 'download':
        cwd => '/tmp',
        command => "wget http://nginx.org/download/nginx-$version.tar.gz",
        creates => "/tmp/nginx-$version.tar.gz",
        #        path => ['/bin', '/usr/bin'],
      } ->

        # Extract archive
      exec { 'extract':
        cwd => '/tmp',
        command => "tar xvzf  nginx-$version.tar.gz",
        #        path => ['/bin', '/usr/bin'],
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
        --pid-path=/tmp/nginx.pid \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --with-http_ssl_module \
        --with-pcre=pcre3 \
        --with-pcre-jit \
        --with-zlib=zlib'",
        #        user => 'root',
        #        path => ['/bin', '/usr/bin'],
      } ->

        # Make
      exec { 'make':
        cwd => "/tmp/nginx-$version",
        command => 'make -j`nproc`',
        #        user => 'root',
        #        path => ['/bin', '/usr/bin'],
      } ->

        # Install
      exec { 'install':
        cwd => "/tmp/nginx-$version",
        command => 'make install',
        #        user => 'root',
        #        path => ['/bin', '/usr/bin'],
      } ->

        # Systemd file as /lib/systemd/system/nginx.service
      file { 'systemd':
        path => '/lib/systemd/system/nginx.service',
        ensure => 'file',
        source => 'puppet:///modules/nginx/nginx.service',
      } ->

        # Ensure the service is running
      service { 'nginx':
        enable => true,
        ensure => 'running',
      }
    }
}