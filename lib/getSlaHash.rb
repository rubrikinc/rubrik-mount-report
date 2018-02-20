require 'restCall.rb'
# Grab Requested [item] from hash and return ony that value
def getSlaHash()
  clusterId = Hash[restCall('rubrik','/api/v1/cluster/me','','get')]['id']
  hash = Hash[restCall('rubrik',"/api/v1/sla_domain?primary_cluster_id=local",'','get')]
  array = hash['data']
  out = Hash.new
  array.each do |x|
    out[x['id']] = x['name']
  end
  return out
end
