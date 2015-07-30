##
#Custom fact for getting contrail config version (useful during upgrades)
#Since this Config control and config are in the same host, we will use this factor
#for evaluating the version of config and control

require 'Facter'

config_version=%x{/usr/bin/dpkg-query -W -f='${Version}\n' contrail-config}
control_version=%x{/usr/bin/dpkg-query -W -f='${Version}\n' contrail-control}
vrouter_version=%x{/usr/bin/dpkg-query -W -f='${Version}\n' contrail-vrouter-agent}

config_version_val=config_version.split('~')[0]
control_version_val=control_version.split('~')[0]
vrouter_version_val=vrouter_version.split('~')[0]

Facter.add('contrail_config_version') do
  setcode do
    config_version
  end
end

Facter.add('contrail_control_version') do
  setcode do
    control_version
  end
end

Facter.add('contrail_vrouter_version') do
  setcode do
    control_version
  end
end

