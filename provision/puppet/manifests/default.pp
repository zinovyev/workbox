file { 'puppet.example':
  path    => "/vagrant/puppet.example",
  ensure  => file,
  # mode => 0644,
  content => "The test file of puppet!"
}