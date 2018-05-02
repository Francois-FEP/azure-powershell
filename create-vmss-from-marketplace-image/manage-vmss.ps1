# List VM Scale Sets  
Get-AzureRmVmss | select *


# Install Antimalware on VMSS

$rgname = 'flip'
$vmssname = 'flip'
$location = 'westeurope'
# Retrieve the most recent version number of the extension.
$allVersions= (Get-AzureRmVMExtensionImage -Location $location -PublisherName "Microsoft.Azure.Security" -Type "IaaSAntimalware").Version
$versionString = $allVersions[($allVersions.count)-1].Split(".")[0] + "." + $allVersions[($allVersions.count)-1].Split(".")[1]
$VMSS = Get-AzureRmVmss -ResourceGroupName $rgname -VMScaleSetName $vmssname
echo $VMSS
Add-AzureRmVmssExtension -VirtualMachineScaleSet $VMSS -Name "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -Type "IaaSAntimalware" -TypeHandlerVersion $versionString -AutoUpgradeMinorVersion $true
Update-AzureRmVmss -ResourceGroupName $rgname -Name $vmssname -VirtualMachineScaleSet $VMSS 

# List scale set profiles and config
Get-AzureRmVmss -Name demovmss -ResourceGroupName demo-vmss

# Enable the extension and enable monitoring
# $StorageContext = New-AzureStorageContext -StorageAccountName "demovmssdiag423" -StorageAccountKey (Get-AzureStorageKey -StorageAccountName "demovmssdiag423").PrimaryP
# Get-AzureRmVmss -ResourceGroupName $rgname -VMScaleSetName $vmssname | Set-AzureVMMicrosoftAntimalwareExtension -AntimalwareConfigFile 'C:\configuration\contosoVM.json" -Monitoring ON -StorageContext $StorageContext' | Update-AzureRmVmss -ResourceGroupName $rgname -Name $vmssname -VirtualMachineScaleSet $VMSS 

# Update OS Profile detials

$AdminUsername = 'sysadmin'
$AdminPassword = 'P@ssw0rd!!!!'
$rgname = 'demo-vmss'
$vmssname = 'demovmss'
Get-AzureRmVmss -ResourceGroupName $rgname -VMScaleSetName $vmssname | Set-AzureRmVmssOSProfile - -AdminUsername $AdminUsername -AdminPassword $AdminPassword -WindowsConfigurationEnableAutomaticUpdate $true

