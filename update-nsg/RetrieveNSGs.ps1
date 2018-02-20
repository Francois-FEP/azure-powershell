#Import the NSG csv management module
import-module '.\AzureCustomRMNetworkSecurityGroup.psm1'
#Retrieve all NSGs in subscription
$nsgs=Get-AzureRmNetworkSecurityGroup | select Name,ResourceGroupName 
#export all NSGs into individual CSV files
ForEach ($nsg in $nsgs) {
$name=$nsg.name
$csvpath="$name.csv"
Export-AzureRmNetworkSecurityGroup -CSVPath .\$csvpath -ResourceGroupName $nsg.ResourceGroupName -NetworkSecurityGroupName $nsg.name
}
#Create seperate csv file to contain the NSG properties, such as name, resouce group and associated csv name.
Get-AzureRmNetworkSecurityGroup | select @{name="csvpath"; expression={".\"+$_.Name+".csv"}},Name,ResourceGroupName|export-csv -path .\NSGs.csv -NoTypeInformation