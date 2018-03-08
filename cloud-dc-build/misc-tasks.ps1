#MISC Tasks
#
#Find power state of VM
Get-AzureRmVM `
    -ResourceGroupName "myResourceGroupVM" `
    -Name "myVM" `
    -Status | Select @{n="Status"; e={$_.Statuses[1].Code}}

#Stop virtual machine
Stop-AzureRmVM -ResourceGroupName "myResourceGroupVM" -Name "myVM" -Force

#Start virtual machine
Start-AzureRmVM -ResourceGroupName "myResourceGroupVM" -Name "myVM"

#Delete resource group
Remove-AzureRmResourceGroup -Name "myResourceGroupVM" -Force

#List VM sizes available in region
Get-AzureRmVmSize -Location "UK South" | Sort-Object Name | ft Name, NumberOfCores, MemoryInMB, MaxDataDiskCount -AutoSize

#List Azure VM size SKU available in region
Get-AzureRmComputeResourceSku | where {$_.Locations -icontains "westeurope"}