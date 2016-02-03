# modules/openssl/manifests/init.pp

class openssl {

  package { 'openssl':
    ensure => installed,
  }

  $libssl_packages = [
    'libssl1.0.0',
    'libssl-dev',
  ]
  package { $libssl_packages:
    ensure => installed,
  }

  Package['openssl'] -> Package['libssl-dev']
}