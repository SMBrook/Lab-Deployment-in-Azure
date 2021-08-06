@minLength(1)
param hypervHostDnsName string = 'hypervhostupdateme'

@minLength(1)
param HyperVHostAdminUserName string = 'rootadmin'

@secure()
param HyperVHostAdminPassword string

var OnPremVNETPrefix = '10.0.0.0/16'
var OnPremVNETSubnet1Name = 'VMHOST'
var OnPremVNETSubnet1Prefix = '10.0.0.0/24'
var HyperVHostName_var = 'HYPERVHOST'
var HyperVHostImagePublisher = 'MicrosoftWindowsServer'
var HyperVHostImageOffer = 'WindowsServer'
var HyperVHostWindowsOSVersion = '2019-Datacenter'
var HyperVHostOSDiskName = '${HyperVHostName_var}-OSDISK'
var HyperVHostVmSize = 'Standard_E4s_v3'
var HyperVHostVnetID = OnPremVNET.id
var HyperVHostSubnetRef = '${HyperVHostVnetID}/subnets/${OnPremVNETSubnet1Name}'
var HyperVHostNicName_var = '${HyperVHostName_var}-NIC'
var HyperVHost_PUBIPName_var = '${HyperVHostName_var}-PIP'
var HyperVHostConfigArchiveFolder = '.'
var HyperVHostConfigArchiveFileName = 'HyperVHostConfig.zip'
var HyperVHostConfigURL = 'https://github.com/SMBrook/Lab-Deployment-in-Azure/blob/master/HyperVHostConfig.zip?raw=true'
var ConfigureVMIPConfigURL = 'https://github.com/SMBrook/Lab-Deployment-in-Azure/blob/master/ConfigureVMIP.zip?raw=true'
var HyperVHostInstallHyperVScriptFolder = '.'
var HyperVHostInstallHyperVScriptFileName = 'InstallHyperV.ps1'
var HyperVHostInstallHyperVURL = 'https://raw.githubusercontent.com/SMBrook/Lab-Deployment-in-Azure/master/InstallHyperV.ps1'

resource OnPremVNET 'Microsoft.Network/virtualNetworks@2018-12-01' = {
  name: 'OnPremVNET'
  location: resourceGroup().location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        OnPremVNETPrefix
      ]
    }
    subnets: [
      {
        name: OnPremVNETSubnet1Name
        properties: {
          addressPrefix: OnPremVNETSubnet1Prefix
        }
      }
    ]
  }
  dependsOn: []
}

resource HyperVHost_PUBIPName 'Microsoft.Network/publicIPAddresses@2018-12-01' = {
  name: HyperVHost_PUBIPName_var
  location: resourceGroup().location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: hypervHostDnsName
    }
  }
  dependsOn: []
}

resource HyperVHostNicName 'Microsoft.Network/networkInterfaces@2018-12-01' = {
  name: HyperVHostNicName_var
  location: resourceGroup().location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: HyperVHostSubnetRef
          }
          publicIPAddress: {
            id: HyperVHost_PUBIPName.id
          }
        }
      }
    ]
  }
}

resource HyperVHostName 'Microsoft.Compute/virtualMachines@2018-10-01' = {
  name: HyperVHostName_var
  location: resourceGroup().location
  tags: {
    Purpose: 'LabDeployment'
  }
  properties: {
    hardwareProfile: {
      vmSize: HyperVHostVmSize
    }
    osProfile: {
      computerName: HyperVHostName_var
      adminUsername: HyperVHostAdminUserName
      adminPassword: HyperVHostAdminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: HyperVHostImagePublisher
        offer: HyperVHostImageOffer
        sku: HyperVHostWindowsOSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        diskSizeGB: 500
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: HyperVHostNicName.id
        }
      ]
    }
  }
}

resource HyperVHostName_InstallHyperV 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  parent: HyperVHostName
  name: 'InstallHyperV'
  location: resourceGroup().location
  tags: {
    displayName: 'Install Hyper-V'
  }
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.4'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        HyperVHostInstallHyperVURL
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${HyperVHostInstallHyperVScriptFolder}/${HyperVHostInstallHyperVScriptFileName}'
    }
  }
}

resource HyperVHostName_HyperVHostConfig 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  parent: HyperVHostName
  name: 'HyperVHostConfig'
  location: resourceGroup().location
  tags: {
    displayName: 'HyperVHostConfig'
  }
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: concat(HyperVHostConfigURL)
        script: 'HyperVHostConfig.ps1'
        function: 'Main'
      }
      configurationArguments: {
        nodeName: HyperVHostName_var
      }
    }
  }
  dependsOn: [
    HyperVHostName_InstallHyperV
  ]
}

resource ConfigureVMIP 'Microsoft.Compute/virtualMachines/extensions@2017-12-01' = {
  name: 'ConfigureVMIP'
  location: resourceGroup().location
  tags: {
    displayName: 'ConfigureVMIP'
  }
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.9'
    autoUpgradeMinorVersion: true
    settings: {
      configuration: {
        url: concat(ConfigureVMIPConfigURL)
        script: 'ConfigureVMIP.ps1'
        function: 'Main'
      }
      configurationArguments: {
        nodeName: HyperVHostName_var
      }
    }
  }
  dependsOn: [
    HyperVHostName_HyperVHostConfig
  ]
}
