# modules/openssl/manifests/init.pp

class openssl {
  package { 'openssl':
    ensure => installed,
  }

  package { 'libssl-dev':
    ensure => installed,
  }
}