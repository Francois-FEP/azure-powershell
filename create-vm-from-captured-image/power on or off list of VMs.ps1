# https://docs.microsoft.com/en-us/azure/virtual-machines/windows/create-vm-generalized-managed
#
#

# Make sure the latest version of AzureRM.Compute and AzureRM.Network PowerShell modules are installed. 
#
# Install-Module AzureRM.Compute,AzureRM.Network

# Check VM status
# Get-AzureRmVM -Status

# Import detials of servers
$vmListFile = "Servers.csv"
$vms = import-csv $vmListFile

# Set additional parameters
$ServiceRGNamePrefix = "SPL-PROD-"

# Configure network settings
ForEach ($machine in $vms) {

# Set general parameters

        $vmName = $machine.Name
        $rgName= $ServiceRGNamePrefix + $($machine.Service)

Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName
# Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

}
