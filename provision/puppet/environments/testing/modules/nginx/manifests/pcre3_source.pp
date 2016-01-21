# modules/nginx/manifests/pcre3_source.pp

class nginx::pcre3_source (
    $path = '/tmp/pcre3_source',
) {
    # Install additional libraries
    $libpcre3_package = ['libpcre3', 'libpcre3-dev']
    package { $libpcre3_package:
        ensure => installed,
    }

    # Get pcre3 sources
    exec {'get_pcre3_source':
        cwd => "/tmp",
        command => "apt-get source libpcre3 && mv pcre3-* $path",
        require => Package[$libpcre3_package]
        onlyif => ['test ! -d pcre3'],
    }
}