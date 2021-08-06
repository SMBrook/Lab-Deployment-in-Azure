<# 
Microsoft Lab Environment - Azure Backup
.File Name
 - HyperVHostConfig.ps1
 
.What calls this script?
 - 

.What does this script do?  
 - Creates an Internal Switch in Hyper-V called "NatSwitch"
    
 - Downloads an images of several servers for the lab environment

 - Repartitions the OS disk to 400GB in size

 - Add a new IP address to the Internal Network for Hyper-V attached to the NATSwitch

 - Creates a NAT Network on 172.16.0.0/24

 - Creates the Virtual Machines in Hyper-V

 - Issues a Start Command for the new VMs
#>

Configuration Main
{
	Param ( [string] $nodeName )

	Import-DscResource -ModuleName 'PSDesiredStateConfiguration', 'xHyper-V'

	node $nodeName
  	{
		# Ensures a VM with default settings
        xVMSwitch InternalSwitch
        {
            Ensure         = 'Present'
            Name           = 'NatSwitch'
            Type           = 'Internal'
        }
		
		Script ConfigureHyperV
    	{
			GetScript = 
			{
				@{Result = "ConfigureHyperV"}
			}	
		
			TestScript = 
			{
           		return $false
        	}	
		
			SetScript =
			{
				$zipDownload = "https://sarahlabfiles.blob.core.windows.net/migratelab/MigrateLabVM.zip"
				$downloadedFile = "D:\MigrateLabVMs.zip"
				$vmFolder = "C:\VM"
				Resize-Partition -DiskNumber 0 -PartitionNumber 2 -Size (400GB)
				Invoke-WebRequest $zipDownload -OutFile $downloadedFile
				Add-Type -assembly "system.io.compression.filesystem"
				[io.compression.zipfile]::ExtractToDirectory($downloadedFile, $vmFolder)
				$NatSwitch = Get-NetAdapter -Name "vEthernet (NatSwitch)"
				New-NetIPAddress -IPAddress 192.168.2.1 -PrefixLength 24 -InterfaceIndex $NatSwitch.ifIndex
				New-NetNat -Name NestedVMNATnetwork -InternalIPInterfaceAddressPrefix 172.16.0.1/24 -Verbose
				New-VM -Name AD01 `
					   -MemoryStartupBytes 2GB `
					   -BootDevice VHD `
					   -VHDPath 'C:\VM\AD01.vhdx' `
                       -Path 'C:\VM' `
					   -Generation 1 `
				       -Switch "NATSwitch"
				Start-VM -Name AD01
				New-VM -Name FS01 `
				-MemoryStartupBytes 2GB `
				-BootDevice VHD `
				-VHDPath 'C:\VM\FS01.vhdx' `
				-Path 'C:\VM' `
				-Generation 1 `
				-Switch "NATSwitch"
				Start-VM -Name FS01
				New-VM -Name SQL01 `
				-MemoryStartupBytes 8GB `
				-BootDevice VHD `
				-VHDPath 'C:\VM\SQL01.vhdx' `
				-Path 'C:\VM' `
				-Generation 1 `
				-Switch "NATSwitch"
				Start-VM -Name SQL01
				New-VM -Name WEB01 `
				-MemoryStartupBytes 2GB `
				-BootDevice VHD `
				-VHDPath 'C:\VM\WEB01.vhdx' `
				-Path 'C:\VM' `
				-Generation 1 `
				-Switch "NATSwitch"
				Start-VM -Name WEB01
			}
		}
		Script SetVMIP
    	{
			GetScript = 
			{
				@{Result = "SetVMIP"}
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
			}
		}
  	}
}

