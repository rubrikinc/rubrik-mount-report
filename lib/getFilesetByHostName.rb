require 'getVm.rb'

def getFilesetByHostName (machineName)
    #managedId = findVmItem(machineName,'managedId')
    p = '/api/v1/fileset?search_value=' + machineName
    puts "Looking up #{p}"
    o = restCall('rubrik',p,'','get')
end
