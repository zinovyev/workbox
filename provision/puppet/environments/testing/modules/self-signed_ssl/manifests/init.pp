# modules/nginx/manifests/init.pp

class self-signed_ssl (
    $cert_file = '/etc/ssl/certs/local.dev.crt',
    $cert_key_file = '/etc/ssl/certs/local.dev.key',
) {
    exec { 'generate_self_signed_ssl':
        command => "-subj '/C=GB/ST=London/L=Fulham/O=Local/OU=Development/CN=local.dev/emailAddress=email@local.dev'  \
        -keyout $cert_key_file \
        -out $cert_file"
    }
}