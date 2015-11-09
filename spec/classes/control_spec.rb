require 'spec_helper'

describe 'contrail::control' do
  let :facts do
    {
    :operatingsystem => 'Ubuntu',
    :osfamily        => 'Debian',
    :lsbdistid       => 'ubuntu',
    :lsbdistcodename => 'trusty',
    :ipaddress       => '10.1.1.1',
    :hostname        => 'node1',
    :interfaces      => 'eth0,lo',
    :ipaddress_eth0  => '10.1.1.1',
    }
  end

  context 'with defaults' do
    it do
      should contain_package('contrail-control').with({'ensure' => 'present'})
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/hostname=node1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/server=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/password=10.1.1.1/)
      should contain_file('/etc/contrail/contrail-control.conf').with_content(/user=10.1.1.1/)
      should contain_service('contrail-control').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/contrail-control.conf]',
        'require'   => 'Package[contrail-control]'
      })
    end
  end
  context 'with contrail-dns' do
    let :params do
      {
      :enable_dns => true,
      :dns_port   => '10000',
      }
    end
    it do
      should contain_package('contrail-dns').with({'ensure' => 'present'})
      should contain_file('/etc/contrail/dns.conf').with_content(/hostip=10.1.1.1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/hostname=node1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/server=10.1.1.1/)
      should contain_file('/etc/contrail/dns.conf').with_content(/password=10.1.1.1.dns/)
      should contain_file('/etc/contrail/dns.conf').with_content(/user=10.1.1.1.dns/)
      should contain_service('contrail-dns').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => 'File[/etc/contrail/dns.conf]',
        'require'   => 'Package[contrail-dns]'
      })
      should contain_file('/etc/contrail/dns/named.conf').with_content(/listen-on port 10000/)
      should contain_file('/etc/contrail/supervisord_control_files/contrail-named.ini')
      should contain_service('contrail-named').with({
        'ensure'    => 'running',
        'enable'    => true,
        'subscribe' => '[File[/etc/contrail/dns/named.conf]{:path=>"/etc/contrail/dns/named.conf"}, File[/etc/contrail/supervisord_control_files/contrail-named.ini]{:path=>"/etc/contrail/supervisord_control_files/contrail-named.ini"}]',
        'require'   => 'Package[contrail-dns]'
      })
    end
  end
end
