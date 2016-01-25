# modules/self-signed_ssl/manifests/init.pp

class ss_ssl (
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
) {
  class { 'openssl': }

  # Sinse puppet does not allow recursive directories by default, you should use exec
  exec { 'cert_dir':
    creates => $cert_dir,
    command => "mkdir -p ${cert_dir}",
    onlyif => "test ! -e ${cert_dir}",
  }

  # Generate a self-signed sertificate file
  exec { 'generate_self_signed_ssl':
    command => "openssl req -newkey rsa:4096 -days 365 -nodes -x509 \
      -subj '/C=${subj_country}/ST=${subj_state}/L=${subj_locality}/O=${subj_organization}/OU=${subj_unit}/CN=${subj_domain}/emailAddress=${subj_email}' \
      -keyout ${cert_key_file} \
      -out ${cert_file}",
    cwd     => $cert_dir,
    require => [
      Class['openssl'],
      Exec['cert_dir'],
    ],
    onlyif  => [
      "test ! -e ${cert_dir}/${cert_file}",
      "test ! -e ${cert_dir}/${cert_key_file}",
    ],
    creates => [
      "${cert_dir}/${cert_file}",
      "${cert_dir}/${cert_key_file}",
    ],
  }
}