# Add Av Sets & NSG
# set disk name
# Add Diag Storage Account
###################

Param (
    [string]$location = "West Europe",
    [string]$vmListFile = "Servers.csv"
)

$servers = import-csv $vmListFile

#Set the username and password needed for the administrator account on the virtual machine with Get-Credential:
$cred = Get-Credential -Message "Enter local VM creds"

ForEach ($vm in $servers) {

# Get Resource Group name from Service field
$vmRgName = $vm.VmResourceGroup  
$vmRG = Get-AzureRmResourceGroup -Name $vmRgName

# Check if resource group exists, if not, create ita
if ($vmRG -eq $null)
{
     Write-Output "Service resource group not found so creating it...."
     New-AzureRmResourceGroup -Name $vmRgName -Location $location
}

$vmName = $vm.Name
$vmSize = $vm.Size
$vmSubnet = $vm.Subnet
$imageSKU = $vm.ImageSKU
$pubName = $vm.ImagePublisher
$offerName = $vm.ImageOffer
$dnsPri = $vm.dnsOne
$dnsSec = $vm.dnsTwo
$vmTimeZone = $vm.TimeZone

$pip = New-AzureRmPublicIpAddress -ResourceGroupName $vmRgName -Location $location `
    -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name ($vmName+"-pip")

$nic = New-AzureRmNetworkInterface -Name ($vmName+"-NIC") -ResourceGroupName $vmRgName `
    -Location $location `
    -SubnetId ("/subscriptions/db78b667-b7c2-430a-bb76-16e62f4c7563/resourceGroups/rg-core-networking/providers/Microsoft.Network/virtualNetworks/TechKB-vNET/subnets/"+$vmSubnet) `
    -IpConfigurationName ($vmName+"-IPConfig") `
    -DnsServer $dnsPri, $dnsSec `
    -PublicIpAddressId $pip.Id

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName $vmName -TimeZone $vmTimeZone -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName $pubName -Offer $offerName `
    -Skus $imageSKU -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

# Create the virtual machine
New-AzureRmVM -ResourceGroupName $vmRgName -Location $location -VM $vmConfig

}

Write-Output "Finished VM deployment."