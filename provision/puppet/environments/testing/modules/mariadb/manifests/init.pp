# modules/mariadb/manifests/init.pp

class mariadb {

  # Install base packages for MariaDB
  $mariadb = [
    'mariadb-server',
    'mariadb-client'
  ]
  package { $mariadb:
    ensure => 'installed',
  }
}