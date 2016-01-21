# manifests/init.pp

Exec {
    path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ],
    user => 'root',
}

node default {
    class { 'toolbox': }
    class { 'nginx':
        version => '1.9.9'
    }
    # include nginx
    # include base3
}