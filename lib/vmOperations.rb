require 'rbvmomi'
def shutdownVm(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['fromDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    if vm.runtime.powerState == "poweredOff"
      logme("#{vm.name}","Check Power State",vm.runtime.powerState.capitalize)
      return
    end
    vm.ShutdownGuest
  rescue StandardError=>e
    logme("#{vm.name}","Check Power State", "#{e}")
  end
  while vm.runtime.powerState == "poweredOn"
    logme("#{vm.name}","Ping",vm.runtime.powerState.capitalize)
  end
  logme("#{vm.name}","Check Power State ", vm.runtime.powerState.capitalize)
end

def startVm(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['fromDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    if vm.runtime.powerState == "poweredOn"
      logme("#{vm.name}","Check Power State", vm.runtime.powerState.capitalize)
      return
    end
    vm.PowerOnVM_Task
  rescue StandardError=>e
    logme("#{vm.name}","Check Power State", "#{e}")
  end
  while vm.runtime.powerState == "poweredOff"
    logme("#{vm.name}","Ping",vm.runtime.powerState)
  end
  logme("#{vm.name}","Checking Power State ", vm.runtime.powerState.capitalize)
end

def getVm(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['servers'].sample(1)[0]}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['datacenter']) || fail('datacenter not found')
    return findvm(dc.vmFolder,vmobj['objectName'])
  rescue standardError=>e
    puts e
  end
end


def checkCD(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['fromDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    cd = vm.config.hardware.device.find { |hw| hw.class == RbVmomi::VIM::VirtualCdrom }
    back = RbVmomi::VIM::VirtualCdromRemoteAtapiBackingInfo(deviceName: '')
    spec = RbVmomi::VIM::VirtualMachineConfigSpec(
      deviceChange: [{operation: :edit,
        device: RbVmomi::VIM::VirtualCdrom(
          backing: back, key: cd.key, controllerKey: cd.controllerKey,
          connectable: RbVmomi::VIM::VirtualDeviceConnectInfo(
            startConnected:  false, connected: false, allowGuestControl: true
          )
        )
      }]
    )
    vm.ReconfigVM_Task(spec: spec).wait_for_completion
    logme("#{vm.name}","Reassigning VirtualCdrom", "Complete")
  rescue StandardError=>e
    logme("#{vm.name}","Reassigning VirtualCdrom", "#{e}")
  end
end

def vMotion(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['toDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    ndc = dc.find_datastore(vmobj['toDatastore'])
    migrate_spec = RbVmomi::VIM.VirtualMachineRelocateSpec(datastore: ndc)
    vmotion_task = vm.RelocateVM_Task(spec: migrate_spec)
    status = vmotion_task.info.state
    last_status = status
    while status != "success"
      status = vmotion_task.info.state
      if status != last_status
        logme("#{vm.name}","VMotion Status",status.capitalize)
      end
      sleep 5
      last_status = status
      logme("#{vm.name}","Ping", status)
    end
  rescue StandardError=>e
    logme("#{vm.name}","VMotion ERROR", "#{e}")
  end
end

def checkManagedBy(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['fromDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    if vm.config.managedBy
      vm_cfg = {:managedBy => {:extensionKey => '',:type => ''  } }
      task = vm.ReconfigVM_Task(spec: vm_cfg).wait_for_completion
      logme("#{vm.name}","Clear spec.managedBy", "Complete")
    elsif !vm.config.managedBy
#      vm_cfg = {:managedBy => {:extensionKey => "vCloud Director-2",:type => "VirtualMachine"  } }
#      task = vm.ReconfigVM_Task(spec: vm_cfg).wait_for_completion
      logme("#{vm.name}","Clear spec.managedBy", "Already Clear")
    end
  rescue StandardError=>e
    logme("#{vm.name}","Clear spec.managedBy", "#{e}")
  end
end

def changePortGroup(vcenter,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['fromDatacenter']) || fail('datacenter not found')
    vm = findvm(dc.vmFolder,vmobj['VMName'])
    vm = findvm(dc.vmFolder,vmname)
    pp vm
    #vm.config.hardware.device.each do |x|
    #  puts x.class
    #end
    net = vm.config.hardware.device.find { |hw| hw.class == RbVmomi::VIM::VirtualVmxnet3 }
    # pp cd
  rescue StandardError=>e
    puts e
  end
end

# Need to check runtime.inMaintenanceMode
def checkMaintenanceMode(vcenter,host,vmobj)
  begin
    vim = RbVmomi::VIM.connect(host: "#{vcenter['server']}", user: "#{vcenter['username']}", password: "#{vcenter['password']}", insecure: "true")
    dc = vim.serviceInstance.find_datacenter(vmobj['toDatacenter']) || fail('datacenter not found')
    h = findhost(dc.hostFolder,host[0])
    if h.to_s != "0"
      return h.runtime.inMaintenanceMode.to_s
    end
  rescue StandardError=>e
    logme("#{vmobj['VMName']}","Checking host maintenance mode", "#{e}")
  end
end

def findhost(folder,name)
  name = name[0]
  children = folder.children.find_all
  children.each do |child|
    if child.class == RbVmomi::VIM::HostSystem
      if (child.to_s.include?name)
        found = child
      else
        next
      end
    elsif child.class == RbVmomi::VIM::ClusterComputeResource
      child.host.each do |x|
        if (x.to_s[name])
          found = x
        else
          next
        end
      end
    elsif child.class == RbVmomi::VIM::ComputeResource
      if (child.itself.to_s[name])
        found = x
      else
        next
      end
    elsif child.class == RbVmomi::VIM::HostFolder
      found = findhost(child,name)
    end
    if found.class == RbVmomi::VIM::HostSystem
      return found
    else
      return 0
    end
  end
end

def findvm(folder,name)
  children = folder.children.find_all
  children.each do |child|
    if child.class == RbVmomi::VIM::VirtualMachine
      if (child.name == name)
        found = child
      else
        next
      end
    elsif child.class == RbVmomi::VIM::Folder
      found = findvm(child,name)
    end
    if found.class == RbVmomi::VIM::VirtualMachine
      return found
    end
  end
end
