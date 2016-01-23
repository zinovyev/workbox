# modules/mariadb/manifests/init.pp

class mariadb {

  # Uninstall MySQL packages
  $mysql = [
    'mysql-server',
    'mysql-client',
  ]
  package { $mysql:
    ensure => 'purged',
  }

  # Install base packages for MariaDB
  $mariadb = [
    'mariadb-server',
    'mariadb-client',
  ]
  package { $mariadb:
    ensure  => 'installed',
    require => Package[$mysql],
  }

  # Enable mariadb service
  service { 'mysql.service':
    ensure => 'running',
    enable => true,
    require => Package[$mariadb],
  }
}