# manifests/init.pp

node default {
    class { 'nginx':
        version => '1.9.9'
    }
    # include nginx
    # include base3
}