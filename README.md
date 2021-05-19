# Lab Deployment in Azure

Within this repo you will find an ARM template that deploys a virtual machine within Azure and then helps you build out a small lab environment within that virtual machine that can be used to replicate an on-prem solution you can use to set up Azure Backup, Azure Site Recovery, Azure Migrate, etc. 

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fupdatehyperv%2FVMdeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2Fweeyin83%2FLab-Deployment-in-Azure%2Fupdatehyperv%2FVMdeploy.json" target="_blank">
    <img src="http://armviz.io/visualizebutton.png"/>
</a>
 
## Setup - IP Configuration

The ARM template will deploy a virtual machine within Azure and then install Hyper-V within that virtual machine.  It will also download some VHD files and deploy three servers onto that Hyper-V environment. 

Once the servers are deployed you need to carry out the following configuration within the servers manually: 

- Log into AD01 and set the server to have a static IP configuration as follows: 
    - IP Address: 192.168.2.10
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.2.1
    - Preferred DNS: 127.0.0.1
    - Alternative DNS: 1.1.1.1

- Log into FS01 and set the server to have a static IP configuration as follows:
    - IP Address: 192.168.2.11
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.2.1
    - Preferred DNS: 192.168.2.10
    - Alternative DNS: 1.1.1.1

- Log into SQL01 and set the server to have a static IP configuration as follows:
    - IP Address: 192.168.2.13
    - Subnet Mask: 255.255.255.0
    - Default Gateway: 192.168.2.1
    - Preferred DNS: 192.168.2.10
    - Alternative DNS: 1.1.1.1

- Within WEB01 run the following commands:
    - sudo apt-get update
    - sudo apt-get upgrade  
    - sudo apt-get install "linux-cloud-tools-$(uname -r)" -y
    - sudo apt-get install --install-recommends linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial -y 

## Setup - VM Credentials

Once deployed the credentials for the servers are: 

**Username**: mcwadmin
**Password**: demo@pass123

## Setup - Windows Updates

The VMs that are deployed during this lab environment were patched in May 2021, if you are deploying after this time and you want to get your system up to date there is a script on each VM that you can use to do that, C:\Scripts\patches.ps1 will install a PowerShell module and then check for updates that are missing and install them.  You can run this script and let it run while you carry out other tasks. 

## Credits
Written by: Sarah Lean

Find me on:

* My Blog: https://www.techielass.com
* Twitter: https://twitter.com/techielass
* LinkedIn: http://uk.linkedin.com/in/sazlean
* Github: https://github.com/weeyin83
