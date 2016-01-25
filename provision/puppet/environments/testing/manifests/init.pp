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
  class { 'toolbox': }
  class { 'toolbox::stdlib': }
  class { 'mariadb': }
  class { 'ss_ssl':
    cert_dir => '/etc/ssl/certs2/foo/bar',
  }
  class { 'nginx': }
}