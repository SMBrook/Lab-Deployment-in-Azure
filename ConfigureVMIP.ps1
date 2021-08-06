Configuration Main
{
	Param ( [string] $nodeName )

	Import-Module -Name Hyper-V

	node $nodeName
  	{
		Script ConfigureVMIP
    	{
			GetScript = 
			{
				@{Result = "ConfigureVMIP"}
			}	
		
			TestScript = 
			{
           		return $false
        	}	
		
			SetScript =
			{
				$vmName = "AD01" 

$Msvm_VirtualSystemManagementService = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_VirtualSystemManagementService 

$Msvm_ComputerSystem = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_ComputerSystem -Filter "ElementName='$vmName'" 

$Msvm_VirtualSystemSettingData = ($Msvm_ComputerSystem.GetRelated("Msvm_VirtualSystemSettingData", `
    "Msvm_SettingsDefineState", $null, $null, "SettingData", "ManagedElement", $false, $null) | % {$_})

$Msvm_SyntheticEthernetPortSettingData = $Msvm_VirtualSystemSettingData.GetRelated("Msvm_SyntheticEthernetPortSettingData")

$Msvm_GuestNetworkAdapterConfiguration = ($Msvm_SyntheticEthernetPortSettingData.GetRelated( `
    "Msvm_GuestNetworkAdapterConfiguration", "Msvm_SettingDataComponent", `
    $null, $null, "PartComponent", "GroupComponent", $false, $null) | % {$_})

$Msvm_GuestNetworkAdapterConfiguration.DHCPEnabled = $false
$Msvm_GuestNetworkAdapterConfiguration.IPAddresses = @("192.168.2.10")
$Msvm_GuestNetworkAdapterConfiguration.Subnets = @("255.255.255.0")
$Msvm_GuestNetworkAdapterConfiguration.DefaultGateways = @("192.168.2.1")
$Msvm_GuestNetworkAdapterConfiguration.DNSServers = @("127.0.0.1", "1.1.1.1")

$Msvm_VirtualSystemManagementService.SetGuestNetworkAdapterConfiguration( `
$Msvm_ComputerSystem.Path, $Msvm_GuestNetworkAdapterConfiguration.GetText(1))

Stop-VM -Name AD01 -Force
while ((get-vm -name AD01).state -ne 'Off') { start-sleep -s 5 }
Start-VM -Name AD01

$vmName = "FS01" 

$Msvm_VirtualSystemManagementService = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_VirtualSystemManagementService 

$Msvm_ComputerSystem = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_ComputerSystem -Filter "ElementName='$vmName'" 

$Msvm_VirtualSystemSettingData = ($Msvm_ComputerSystem.GetRelated("Msvm_VirtualSystemSettingData", `
    "Msvm_SettingsDefineState", $null, $null, "SettingData", "ManagedElement", $false, $null) | % {$_})

$Msvm_SyntheticEthernetPortSettingData = $Msvm_VirtualSystemSettingData.GetRelated("Msvm_SyntheticEthernetPortSettingData")

$Msvm_GuestNetworkAdapterConfiguration = ($Msvm_SyntheticEthernetPortSettingData.GetRelated( `
    "Msvm_GuestNetworkAdapterConfiguration", "Msvm_SettingDataComponent", `
    $null, $null, "PartComponent", "GroupComponent", $false, $null) | % {$_})

$Msvm_GuestNetworkAdapterConfiguration.DHCPEnabled = $false
$Msvm_GuestNetworkAdapterConfiguration.IPAddresses = @("192.168.2.11")
$Msvm_GuestNetworkAdapterConfiguration.Subnets = @("255.255.255.0")
$Msvm_GuestNetworkAdapterConfiguration.DefaultGateways = @("192.168.2.1")
$Msvm_GuestNetworkAdapterConfiguration.DNSServers = @("192.168.2.10", "1.1.1.1")

$Msvm_VirtualSystemManagementService.SetGuestNetworkAdapterConfiguration( `
$Msvm_ComputerSystem.Path, $Msvm_GuestNetworkAdapterConfiguration.GetText(1))

Stop-VM -Name FS01 -Force
while ((get-vm -name FS01).state -ne 'Off') { start-sleep -s 5 }
Start-VM -Name FS01

$vmName = "SQL01" 

$Msvm_VirtualSystemManagementService = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_VirtualSystemManagementService 

$Msvm_ComputerSystem = Get-WmiObject -Namespace root\virtualization\v2 `
    -Class Msvm_ComputerSystem -Filter "ElementName='$vmName'" 

$Msvm_VirtualSystemSettingData = ($Msvm_ComputerSystem.GetRelated("Msvm_VirtualSystemSettingData", `
    "Msvm_SettingsDefineState", $null, $null, "SettingData", "ManagedElement", $false, $null) | % {$_})

$Msvm_SyntheticEthernetPortSettingData = $Msvm_VirtualSystemSettingData.GetRelated("Msvm_SyntheticEthernetPortSettingData")

$Msvm_GuestNetworkAdapterConfiguration = ($Msvm_SyntheticEthernetPortSettingData.GetRelated( `
    "Msvm_GuestNetworkAdapterConfiguration", "Msvm_SettingDataComponent", `
    $null, $null, "PartComponent", "GroupComponent", $false, $null) | % {$_})

$Msvm_GuestNetworkAdapterConfiguration.DHCPEnabled = $false
$Msvm_GuestNetworkAdapterConfiguration.IPAddresses = @("192.168.2.13")
$Msvm_GuestNetworkAdapterConfiguration.Subnets = @("255.255.255.0")
$Msvm_GuestNetworkAdapterConfiguration.DefaultGateways = @("192.168.2.1")
$Msvm_GuestNetworkAdapterConfiguration.DNSServers = @("192.168.2.10", "1.1.1.1")

$Msvm_VirtualSystemManagementService.SetGuestNetworkAdapterConfiguration( `
$Msvm_ComputerSystem.Path, $Msvm_GuestNetworkAdapterConfiguration.GetText(1))

Stop-VM -Name SQL01 -Force
while ((get-vm -name SQL01).state -ne 'Off') { start-sleep -s 5 }
Start-VM -Name SQL01
			}
		}
 	}
}



