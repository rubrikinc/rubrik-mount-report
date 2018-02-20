require 'restCall.rb'

# Grab Requested [item] from hash and return ony that value

def findVmItemByName(t, item)
  t = t.upcase
  begin
    h = restCall('rubrik','/api/v1/vmware/vm?is_relic=false&name='+t,'','get')
    h['data'].each do |v|
      if v['name'].upcase == t
        return v[item]
      end
    end
    return false
  rescue StandardError => e
    return false
  end
end

def findVmItemById(t, item)
  begin
    h = restCall('rubrik',"/api/v1/vmware/vm/#{t}",'','get')
    return h[item]
  rescue StandardError => e
    return false
  end
end
 
def getVmdkSize(id)
  begin
    h = restCall('rubrik',"/api/v1/vmware/vm/#{id}",'','get')
    sa = []
    h['virtualDiskIds'].each do |d|
      sa << restCall('rubrik',"/api/v1/vmware/vm/virtual_disk/#{d}",'','get')['size'] 
    end
    return sa.inject(:+)
  rescue StandardError => e
    return false
  end
end
