# modules/base/manifests/init.pp

class base {

    Exec {
        path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
        user => 'root',
    }

    package { ['ntp', 'wget', 'vim', 'build-essential', 'automake', 'coreutils']:
        ensure => installed,
    }

    service {'ntp':
        name => 'ntp',
        ensure => running,
        enable => true,
    }
}