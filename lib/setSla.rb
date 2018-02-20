require 'restCall.rb'

def setSla(mId,id)
    o = restCall('rubrik','/api/v1/vmware/vm/' + mId ,{ "configuredSlaDomainId" => "#{id}"},"patch")
    return o
end
