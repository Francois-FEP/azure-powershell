
$vmcfg = New-AzureRmVMConfig -VMName VmName -VMSize "Standard_DS12_v2" `
-AvailabilitySetId "/subscriptions/7b72fb43-ba77-4600-ad0f-e56c13222b49/resourceGroups/cfs-rg-rds/providers/Microsoft.Compute/availabilitySets/<availabilitysetname>"

$vmcfg | Set-AzureRmVMOSDisk `
 -VhdUri https://<saname>.blob.core.windows.net/vhds/<vmdiskname>.vhd `
 -Name cfs-vm-rdsh01 -CreateOption attach -Windows -Caching ReadWrite

$vmcfg = Add-AzureRmVMNetworkInterface -VM $vmcfg `
-Id "/subscriptions/<subscriptionID>/resourceGroups/<resourcegroupname>/providers/Microsoft.Network/networkInterfaces/<vmnicname>" -Primary

New-AzureRMVM -ResourceGroupName ResourceGroupName `
 -Location "West Europe" -VM $vmcfg -Verbose
