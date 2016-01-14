# modules/base/manifests/init.pp

class base {
    package { ['ntp', 'wget', 'vim', 'build-essential', 'automake', 'coreutils']:
        ensure => installed,
    }

    service {'ntp':
        name => 'ntp',
        ensure => running,
        enable => true,
    }
}