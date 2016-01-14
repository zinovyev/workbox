# nginx_installed.rb

Facter.add("nginx_installed") do
  setcode do
    installed = Facter::Util::Resolution.exec('which nginx &> /dev/null ; echo $?')
    if installed == "0"
        true
    else
        false
    end
  end
end

Facter.add("nginx_service_loaded") do
  setcode do
    loaded = Facter::Util::Resolution.exec('systemctl status nginx &> /dev/null ; echo $?')
    if loaded == "0"
        true
    else
        false
    end
  end
end

Facter.add("nginx_service_exists") do
  setcode do
    exists = Facter::Util::Resolution.exec('ls /lib/systemd/system/nginx.service &>/dev/null ; echo $?')
    if exists == "0"
        true
    else
        false
    end
  end
end