$subscriptionName = "SubscriptionName"                  #specify name of subscription 
$storageAccountName = "saName"                          #specify storage account name 
$storageAccountKey = "saKey"                            #specify the storage account access key obtained from the Access Key section of the storage account 
$srcContainerName = "vhds"                              #specify the source container name 
$dstContainerName = "vhds"                              #specify the destination container name 
$srcBlob = "source.vhd"                                 #specify the source blob name 
$dstBlob = "target.vhd"                                 #specify the destination blob name 
 

$Context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey  
Start-AzureStorageBlobCopy -SrcContainer $srcContainerName -DestContainer $dstContainerName -SrcBlob $srcBlob -DestBlob $dstBlob -Context $Context -DestContext $Context 
Remove-AzureStorageBlob -Container $srcContainerName -Context $Context -Blob $srcBlob 