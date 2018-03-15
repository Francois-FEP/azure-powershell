# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/create-vm-generalized-managed
#
#

# Make sure the latest version of AzureRM.Compute and AzureRM.Network PowerShell modules are installed. 
#
# Install-Module AzureRM.Compute,AzureRM.Network



# Import detials of servers to create 

$vmListFile = "Servers.csv"
$vms = import-csv $vmListFile

# Set additional parameters
# $ServiceRGNamePrefix = "SPL-PROD-"
$location = "West Europe"
$vnetRG = "my_vnet_rg"
$vnetName = "my_vnet"
$vnet = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetRG -Name $vnetName
$diagsSAName = "diagStorageAcc"

# Get local admin creds
$cred = Get-Credential

# Configure network settings
ForEach ($machine in $vms) {


# Set general parameters

        $vmName = $machine.Name
        $imageName = $machine.vmImage
        $imageRG = $machine.imageRG
        $asName = $machine.avSet
        $vmSize = $machine.Size
        $rgName= $machine.Service

        # Get Resource Group name from Service field
        $rg = Get-AzureRmResourceGroup -Name $rgName

        # Check if resource group exists, if not, create it
        if ($rg -eq $null)
        {
                Write-Output "Service resource group not found so creating it...."
                New-AzureRmResourceGroup -Name $rgName -Location $location
        }


        #Set managed image to be deployed
        $image = Get-AzureRMImage -ImageName $imageName -ResourceGroupName $imageRG

        # Check if availability set is needed and if it exists
        if ($asName -ne '')
        {
            $aset = Get-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $asName

            if ($aset -eq $null)
            {
                        Write-Output ("Availability Set " + $asName + " not found so creating it....")
                $aset = New-AzureRmAvailabilitySet -ResourceGroupName $rgName -Name $asName -Location $location -Sku 'Aligned' -PlatformUpdateDomainCount 5 -PlatformFaultDomainCount 2
            }

            $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $aset.Id
        }
        else
        {
            $vm = New-AzureRmVMConfig -VMName $vmName -VMSize $vmSize
        }
                
               
#*************************************************************************
# Create the NIC(s)
#*************************************************************************
        
# Split the Subnet and IP fields
$vmSubnets = $($machine.Subnet).Split(';')
$vmIPs = $($machine.IP).Split(';')

# Iterate through each subnet specified
ForEach ($vmSubnet in $vmSubnets)
{
    $index = $vmSubnets.IndexOf($vmSubnet)
            
    # Get reference to existing subnet
    $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $vmSubnet -VirtualNetwork $vnet

    # Get static private IP associated with current subnet
    if ($index -ge $vmIPs.length)
    {
        $vmPrivateIP = ''
    }
    else
    {
        $vmPrivateIP = $vmIPs[$index]
    }

    # Switch command based on static IP requirement
    if ($vmPrivateIP -ne '')
    {
#        $nic = New-AzureRmNetworkInterface -Name ($vmName.ToLower() + '-NIC') -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id -PrivateIpAddress $vmPrivateIP
        $nic = New-AzureRmNetworkInterface -Name ($vmName + '-NIC') -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id -PrivateIpAddress $vmPrivateIP
    
}
    else
    {
#        $nic = New-AzureRmNetworkInterface -Name ($vmName.ToLower() + '-NIC') -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id
        $nic = New-AzureRmNetworkInterface -Name ($vmName + '-NIC') -ResourceGroupName $rgName -Location $location -SubnetId $subnet.Id

    }

    # Add the NIC to the VM object
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
}

# Create OS Config and add the NIC

$vm = Set-AzureRmVMSourceImage -VM $vm -Id $image.Id
$vm = Set-AzureRmVMOSDisk -VM $vm  -Name ($vmName+"-Disk-0")-StorageAccountType StandardLRS -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
#$vm = Set-AzureRmVMOSDisk -VM $vm  -Name ($vmName+"-Disk-0")-StorageAccountType PremiumLRS -DiskSizeInGB 128 -CreateOption FromImage -Caching ReadWrite
$vm = Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmName -Credential $cred -ProvisionVMAgent -EnableAutoUpdate
$vm = Set-AzureRmVMBootDiagnostics -VM $vm -Enable -ResourceGroupName $rgName -StorageAccountName $diagsSAName


# Create VM

New-AzureRmVM -VM $vm -ResourceGroupName $rgName -Location $location


}
