# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/hybrid-use-benefit-licensing
 
# Convert to using Azure Hybrid Benefit for Windows Server
$vm = Get-AzureRmVM -ResourceGroup "rg-name" -Name "vm-name"
$vm.LicenseType = "Windows_Server"
Update-AzureRmVM -ResourceGroupName "rg-name" -VM $vm

# Convert back to pay as you go
$vm = Get-AzureRmVM -ResourceGroup "rg-name" -Name "vm-name"
$vm.LicenseType = "None"
Update-AzureRmVM -ResourceGroupName rg-name -VM $vm

# Verify your VM is utilizing the licensing benefit
Get-AzureRmVM -ResourceGroup "rg-name" -Name "vm-name"

# List all Azure Hybrid Benefit for Windows Server VMs in a subscription
$vms = Get-AzureRMVM 
foreach ($vm in $vms) {"VM Name: " + $vm.Name, "   Azure Hybrid Benefit for Windows Server: "+ $vm.LicenseType}