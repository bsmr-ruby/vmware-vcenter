require 'lib/puppet/provider/vcsa'

Puppet::Type.type(:vcsa_java).provide(:vcsa_java, :parent => Puppet::Provider::Vcsa ) do
  @doc = 'Manages vCSA java'

  mk_resource_methods

  def flush
    create
  end

  def create
    transport.send("vpxd_servicecfg jvm-max-heap write #{resource[:tomcat]} #{resource[:inventory]} #{resource[:sps]}")
  end

  def transport
    self.class.transport(resource)
  end

  def exists?
    transport.send('vpxd_servicecfg jvm-max-heap read')
    # populating  @property_hash allows us to use mk_resource_methods
    result = Hash[*transport.result.split("\n").collect{|x| x.split('=',2)}.flatten]

    @property_hash[:tomcat]    = result['VC_MAX_HEAP_SIZE_TOMCAT']
    @property_hash[:inventory] = result['VC_MAX_HEAP_SIZE_QS']
    @property_hash[:sps]       = result['VC_MAX_HEAP_SIZE_SPS']
    true
  end
end