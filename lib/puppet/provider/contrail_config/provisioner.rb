require_relative '../contrailBGP'

Puppet::Type.type(:contrail_config).provide(
  :provisioner,
  :parent => Puppet::Provider::ContrailBGP
) do

  commands  :provision_config => '/usr/sbin/contrail-provision-config'

  def getUrl
    'http://' + resource[:api_server_address] + ':' + resource[:api_server_port] + '/config'
  end

  def exists?
  end

  def create
    provision_config(
      '--admin_user',resource[:admin_user],
      '--admin_password',resource[:admin_password],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port',resource[:api_server_port],
      '--host_name',resource[:name],
      '--host_ip',resource[:host_address],
      '--admin_tenant_name',resource[:admin_tenant],
      '--oper add')
  end

  def destroy
    provision_config(
      '--admin_user',resource[:admin_user],
      '--admin_password',resource[:admin_password],
      '--admin_tenant_name',resource[:admin_tenant],
      '--api_server_ip', resource[:api_server_address],
      '--api_server_port',resource[:api_server_port],
      '--host_name',resource[:name],
      '--oper del')
  end

  def host_address
    getElement(getUrl,resource[:name],'address')
  end

  def host_address=(value)
    fail('Cannot change Existing value, please remove and recreate the Config node object (' + resource[:name] + ')')
  end

  def router_asn
    getElement(getUrl,resource[:name],'autonomous_system')
  end

  def router_asn=(value)
    fail('Cannot change Existing value, please remove and recreate the Config node object (' + resource[:name] + ')')
  end

end