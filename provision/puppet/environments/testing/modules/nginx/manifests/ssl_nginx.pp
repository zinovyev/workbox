# modules/nginx/manifests/init.pp

class nginx::ssl_nginx (
  $cert_dir = '/etc/ssl/certs',
  $cert_file = 'local.dev.crt',
  $cert_key_file = 'local.dev.key',
  $subj_country = 'RU',
  $subj_state = 'Moscow',
  $subj_locality = 'Moscow',
  $subj_organization = 'Example',
  $subj_unit = 'Example Unit',
  $subj_domain = 'example.org',
  $subj_email = 'name@example.org',
) inherits ss_ssl {

  # Change cert file permissions
  $cert_path = "${cert_dir}/${cert_file}"
  $cert_key_path = "${cert_dir}/${cert_key_file}"
  $cert_dir_hash = md5($cert_dir)
  file { $cert_path:
    ensure  => file,
    owner   => $nginx::owner,
    group   => $nginx::group,
    mode    => "0600",
    require => [
      Exec["cert_dir_${cert_dir_hash}"],
      Class['nginx'],
    ]
  }
  file { $cert_key_path:
    ensure  => file,
    owner   => $nginx::owner,
    group   => $nginx::group,
    mode    => "0600",
    require => [
      Exec["cert_dir_${cert_dir_hash}"],
      Class['nginx'],
    ],
  }

  # Create the default config
  file { '/etc/nginx/sites-available/ssl_default.conf':
    ensure   => 'file',
    content => template('nginx/ssl_default.conf.erb'),
    require  => [
      File['/etc/nginx/sites-available'],
    ]
  }

  # Enable default site
  file { '/etc/nginx/sites-enabled/ssl_default.conf':
    ensure  => 'link',
    target  => '/etc/nginx/sites-available/ssl_default.conf',
    require => [
      File['/etc/nginx/sites-available/ssl_default.conf'],
      File['/etc/nginx/sites-enabled'],
    ],
    notify  => Service['nginx.service'],
  }
}