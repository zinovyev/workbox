# modules/nginx/manifests/init.pp

class nginx {
    # Download nginx sources
    exec { 'download':
        cwd => '/tmp',
        command => 'wget http://nginx.org/download/nginx-1.8.0.tar.gz',
        creates => '/tmp/nginx-1.8.0.tar.gz',
        path => ['/bin', '/usr/bin']
    }
    # file { '/tmp/nginx.tar.gz':
    #     ensure => present,
    #     source => 'http://nginx.org/download/nginx-1.8.0.tar.gz'
    # }
}