#Import the NSG csv management module
import-module '.\AzureCustomRMNetworkSecurityGroup.psm1'
#Import the csv containing the NSG properties
$file="NSGs.csv"
$nsgs = import-csv $file 
#Update each NSG with any changes that have been made in the CSV files
ForEach ($nsg in $nsgs) {
Update-AzureRmCustomNetworkSecurityGroup -CSVPath $nsg.csvpath -ResourceGroupName $nsg.resourcegroupname -NetworkSecurityGroupName $nsg.name
}