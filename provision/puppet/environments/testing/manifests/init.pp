# manifests/init.pp

Exec {
  path => [
    '/bin/',
    '/sbin/',
    '/usr/bin/',
    '/usr/sbin/',
    '/usr/local/bin',
    '/usr/local/sbin',
    '/opt/puppetlabs/bin',
  ],
  user => 'root',
}

node default {

  class { 'stdlib': }
  class { 'toolbox': }
  class { 'mariadb': }
  class { 'nginx': }
  class { 'nginx::ssl_nginx':
    cert_dir => '/etc/nginx/certs',
  }
}