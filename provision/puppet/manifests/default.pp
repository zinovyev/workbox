file {'/vagrant/puppet'
  'ensusre' => present,
  'mode' => 0644,
  'content' => 'The test file of puppet!'
}