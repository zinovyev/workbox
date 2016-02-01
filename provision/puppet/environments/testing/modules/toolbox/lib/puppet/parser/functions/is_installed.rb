# Check if a package is installed or not
#

module Puppet::Parser::Functions
  newfunction(:is_installed, :type => :rvalue) do |args|
    package_name = args[0]
    command = "which #{package_name} &>/dev/null"
    package = system( command )
  end
end