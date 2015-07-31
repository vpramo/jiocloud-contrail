#
# Class contrail::control
#
class contrail::control (
  $package_ensure          = present,
  $contrail_control_daemon = 'upstart',
  $control_ip_list         = [$::ipaddress],
  $config_ip               = $::ipaddress,
  $contrail_ip             = $::ipaddress,
  $log_level               = 'SYS_INFO',
  $log_file_size           = 10737418240,
  $log_local               = 1,
) {

  ##Check the version of contrail and assign correct service names
  # This may need to be removed after the contrail upgrade and stablization 
  # as this is only required because we are moving from upstart to supervisor
  # for contrail
  if $contrail_control_daemon {
    if $contrail_control_daemon == 'supervisor' {
      $contrail_control_service   ='supervisor-control'
      $contrail_dns_service       ='supervisor-control'
      file { '/etc/init/contrail-control.conf' :
        ensure  => absent,
      }
      file { '/etc/init/contrail-dns.conf' :
        ensure  => absent,
      }
    }
    else
    {
      $contrail_control_service   ='contrail-control'
      $contrail_dns_service       ='contrail-dns'
    }
  }
  else
  {
      $contrail_control_service   ='contrail-control'
      $contrail_dns_service       ='contrail-dns'
  }


  package {'contrail-control':
    ensure => $package_ensure,
  }


  package {'contrail-dns':
    ensure => $package_ensure,
  }
  ##
  # DNS configuration
  ##

  file { '/etc/contrail/dns.conf' :
    ensure  => present,
    content => template("${module_name}/dns.conf.erb"),
  }

  service {$contrail_dns_service:
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/contrail/dns.conf'],
    require   => Package['contrail-dns']
  }

  ##
  # control  configuration
  ##

  file { '/etc/contrail/contrail-control.conf' :
    ensure  => present,
    content => template("${module_name}/contrail-control.conf.erb"),
  }

  service {$contrail_control_service:
    ensure    => running,
    enable    => true,
    subscribe => File['/etc/contrail/contrail-control.conf'],
    require   => Package['contrail-control']
  }

}
