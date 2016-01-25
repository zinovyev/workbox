# modules/toolbox/manifests/stdlib.pp

class toolbox::stdlib {
  $module_stdlib = 'puppetlabs-stdlib'

  exec { 'puppet_module_stdlib':
    command => "puppet module install ${module_stdlib}",
    unless  => "puppet module list | grep ${module_stdlib}",
  }
}