#Login to Azure
Login-AzureRmAccount

#List available Subscriptions
Get-AzureRmSubscription

#Select the Subscription to be used
Select-AzureRmSubscription -Subscription "Azure Pass"

$location = "West Europe"
$corenetworkRG = "rg-core-networking"
$vnetName = "TechKB-vNET"

#Create Resource Group to locate all core networking resources
New-AzureRmResourceGroup -Name $corenetworkRG -Location $location

#Create virtual network
$virtualNetwork = New-AzureRmVirtualNetwork -Name $vnetName `
    -ResourceGroupName $corenetworkRG `
    -Location $location `
    -AddressPrefix 10.0.0.0/8


#Add Subnets to virtual network

#1. Create subnet configuration

$subnetConfigPublic = Add-AzureRmVirtualNetworkSubnetConfig `
    -Name Public `
    -AddressPrefix 10.0.0.0/24 `
    -VirtualNetwork $virtualNetwork
  
$subnetConfigPrivate = Add-AzureRmVirtualNetworkSubnetConfig `
    -Name Private `
    -AddressPrefix 10.0.1.0/24 `
    -VirtualNetwork $virtualNetwork

#2. Write Subnet configuration to virtual network
$virtualNetwork | Set-AzureRmVirtualNetwork

#Test by creating a test vm in each Subnet
#Note: The -AsJob option creates the virtual machine in the background, so you can continue to the next step. When prompted, enter the user name and password you want to log in to the virtual machine with.

