# modules/base/manifests/init.pp

class base {
    package { ['ntp', 'wget', 'openssl', 'build-essential']:
        provider => apt,
        ensure => installed,
    }

    service {'ntp':
        name => 'ntp',
        ensure => running,
        enable => true,
    }
}