# modules/nginx/manifests/init.pp

class nginx {

    include base

    # Install additional libraries
    package { ['libpcre3', 'libpcre3-dev', 'zlib1g', 'zlib1g-dev']:
        ensure => installed,
    } ->

    # Download nginx sources
    exec { 'download':
        cwd => '/tmp',
        command => 'wget http://nginx.org/download/nginx-1.8.0.tar.gz',
        creates => '/tmp/nginx-1.8.0.tar.gz',
        path => ['/bin', '/usr/bin'],
    } ->

    # Extract archive
    exec { 'extract':
        cwd => '/tmp',
        command => 'tar xvzf  nginx-1.8.0.tar.gz',
        path => ['/bin', '/usr/bin'],
    } ->

    # Configure
    exec { 'configure':
        cwd => '/tmp/nginx-1.8.0',
        command => 'sh -c ./configure \
            --sbin-path=/usr/local/nginx/sbin/nginx \
            --conf-path=/usr/local/nginx/nginx.conf \
            --pid-path=/tmp/nginx.pid \
            --with-http_ssl_module \
            --with-pcre=/usr/lib/x86_64-linux-gnu/libpcre.so \
            --with-pcre-jit \
            --with-zlib1=/usr/lib/x86_64-linux-gnu/libz.so
        ',
        user => 'root',
        path => ['/bin', '/usr/bin'],
    } ->

    # Make
    exec { 'make':
        cwd => '/tmp/nginx-1.8.0',
        command => 'make -j`nproc`',
        user => 'root',
        path => ['/bin', '/usr/bin'],
    } ->

    # Install
    exec { 'install':
        cwd => '/tmp/nginx-1.8.0',
        command => 'make install',
        user => 'root',
        path => ['/bin', '/usr/bin'],
    }
}