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

  # Backup old configuration (for my.cnf)
  file { '/etc/mysql/my.cnf.bkp':
    ensure  => 'file',
    source  => '/etc/mysql/my.cnf',
    replace => false,
  }

  # Backup old configuration (for mariadb.cnf)
  file { '/etc/mysql/conf.d/mariadb.cnf.bkp':
    ensure  => 'file',
    source  => '/etc/mysql/conf.d/mariadb.cnf',
    replace => false,
  }

  # Create new configuration
  file { '/etc/mysql/conf.d/mariadb.cnf':
    ensure  => 'file',
    content => template('mariadb/mariadb.cnf.erb'),
    notify  => Service['mysql.service'],
    require => File['/etc/mysql/conf.d/mariadb.cnf.bkp'],
  }

  # Drop anonimous user
  exec { 'mysql_remove_anonimous_user':
    command => "mysql -e 'DELETE FROM mysql.user WHERE User=\"\";'"
  }

  # Remove remote root
  exec { 'mysql_remove_remote_root':
    command => "mysql -e 'DELETE FROM mysql.user WHERE User=\"root\" AND Host NOT IN (\"localhost\", \"127.0.0.1\", \"::1\");'"
  }

  # Remove test DB
  exec { 'mysql_remove_test_db':
    command => "mysql -e 'DROP DATABASE IF EXISTS test;'"
  }

  # Flush privileges
  exec { 'mysql_enable_changes':
    command => 'mysql -e "FLUSH PRIVILEGES;"',
    require => [
      Exec['mysql_remove_anonimous_user'],
      Exec['mysql_remove_remote_root'],
      Exec['mysql_remove_test_db'],
    ],
    notify => Service['mysql.service'],
  }

  # Enable mariadb service
  service { 'mysql.service':
    ensure  => 'running',
    enable  => true,
    require => Package[$mariadb],
  }
}