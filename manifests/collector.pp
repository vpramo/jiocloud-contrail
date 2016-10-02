#
# Class: contrail::collector
#   Manage contrail analytics collector
#
# == Parameters
#
#
#
class contrail::collector (
  $package_ensure     = 'present',
  $api_virtual_ip     = '127.0.0.1',
  $discovery_virtual_ip = '127.0.0.1',
  $contrail_ip        = $::ipaddress,
  $collector_ip       = $::ipaddress,
  $config_ip          = $::ipaddress,
  $zk_ip_list         = [$::ipaddress],
  $zk_port            = 2181,
  $kafka_ip_list      = ['127.0.0.1'],
  $kafka_port         = 9092,
  $analytics_data_ttl = 48, ## Number of hours to keep the data
  $cassandra_ip_list  = [$::ipaddress],
  $redis_ip           = $::ipaddress,
  $cassandra_port     = 9042,
  $log_level          = 'SYS_CRIT',
  $log_file_size      = '10737418240',
  $log_local          = 1,
) {

  package {'contrail-analytics':
    ensure => $package_ensure,
  }

  ##
  ## Ensure contrail-analytics-api.conf file is present with right content.
  ##

  file { '/etc/contrail/contrail-analytics-api.conf':
    ensure  => present,
    content => template("${module_name}/contrail-analytics-api.conf.erb"),
    require => Package['contrail-analytics'],
  }

  service {'contrail-analytics-api':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-analytics-api.conf'],
  }

  file { '/etc/contrail/contrail-collector.conf':
    ensure  => present,
    content => template("${module_name}/contrail-collector.conf.erb"),
    require => Package['contrail-analytics'],
  }

 apt::ppa { 'ppa:opencontrail/ppa': }

  service {'contrail-collector':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-collector.conf'],
  }

  file { '/etc/contrail/contrail-query-engine.conf':
    ensure  => present,
    content => template("${module_name}/contrail-query-engine.conf.erb"),
    require => Package['contrail-analytics'],
  }

 file { '/etc/contrail/contrail-alarm-gen.conf':
    ensure  => present,
    content => template("${module_name}/contrail-alarm-gen.conf.erb"),
    require => Package['contrail-analytics'],
  }


  service {'contrail-query-engine':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-query-engine.conf'],
  }

   package { 'contrail-nodemgr':
       ensure => 'present',
  }

   file {'/etc/contrail/contrail-analytics-nodemgr.conf':
     ensure => present,
     content => template("${module_name}/contrail-nodemgr.conf.erb"),
     require => [Package['contrail-analytics'], Package['contrail-nodemgr']]
  }

  
  file {'/etc/init.d/contrail-analytics-nodemgr':
      ensure => present,
      source => "file:///etc/init.d/contrail-collector",
      require => [Package['contrail-analytics'], Package['contrail-nodemgr']]
  }

 file {'/etc/contrail/supervisord_analytics_files/contrail-analytics-nodemgr.ini':
       ensure => present,
       source => "file:///usr/share/doc/contrail-analytics/examples/contrail-analytics-nodemgr.ini",
         require => [Package['contrail-analytics'], Package['contrail-nodemgr']]
   }

   service {'contrail-analytics-nodemgr':
    ensure    => 'running',
    enable    => true,
    subscribe => [File['/etc/contrail/contrail-analytics-nodemgr.conf'],
                  File['/etc/init.d/contrail-analytics-nodemgr'],
                  File['/etc/contrail/supervisord_analytics_files/contrail-analytics-nodemgr.ini']]
  }


   service {'contrail-snmp-collector':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-snmp-collector.conf'],
  }

 service {'contrail-alarm-gen':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-alarm-gen.conf'],
 }



file {'/etc/contrail/contrail-snmp-collector.conf':
     ensure => present,
     content => template("${module_name}/contrail-snmp-collector.conf.erb"),
     require => Package['contrail-analytics']
  }


  service {'contrail-topology':
    ensure    => 'running',
    enable    => true,
    subscribe => File['/etc/contrail/contrail-topology.conf'],
  }


file {'/etc/contrail/contrail-topology.conf':
     ensure => present,
     content => template("${module_name}/contrail-topology.conf.erb"),
     require => Package['contrail-analytics']
  }  


   contrail_database {$::hostname:
    ensure         => present,
    host_address   => $contrail_ip,
    admin_tenant   => $keystone_admin_tenant,
    admin_user     => $keystone_admin_user,
    admin_password => $keystone_admin_password,
    api_server_address  => $api_virtual_ip,
    require        => Service['contrail-api'],
  }
}

