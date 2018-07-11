# https://docs.microsoft.com/en-us/azure/virtual-network/create-vm-accelerated-networking-powershell

#Stop VM
Stop-AzureRmVM -ResourceGroup "myResourceGroup" `
    -Name "myVM"

#Update NIC 

$nic = Get-AzureRmNetworkInterface -ResourceGroupName "myResourceGroup" `
    -Name "myNIC"

$nic.EnableAcceleratedNetworking = $true

$nic | Set-AzureRmNetworkInterface

#Start VM
# Start-AzureRmVM -ResourceGroup "myResourceGroup" `
#    -Name "myVM"



Start-AzureRmVM -ResourceGroup "ATLAS-RES" `
    -Name "aapdvm001"