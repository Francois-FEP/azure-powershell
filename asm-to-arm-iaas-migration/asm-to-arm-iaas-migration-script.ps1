# Install the latest version of Azure PowerShell

    Install-Module AzureRM
    Install-Module Azure

# Set your subscription and sign up for migration

    Login-AzureRmAccount
    Get-AzureRMSubscription | Sort Name | Select Name
    Select-AzureRmSubscription –SubscriptionName "My Azure Subscription"
    Register-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate
    
    # Check that the provider is registered
    Get-AzureRmResourceProvider -ProviderNamespace Microsoft.ClassicInfrastructureMigrate

    Add-AzureAccount
    Get-AzureSubscription | Sort SubscriptionName | Select SubscriptionName
    Select-AzureSubscription –SubscriptionName "My Azure Subscription"

# Make sure you have enough Azure Resource Manager Virtual Machine vCPUs in the Azure region of your current deployment or VNET

    Get-AzureRmVMUsage -Location "North Europe"

# Option 1 - Migrate virtual machines in a cloud service (not in a virtual network)

# Get the list of cloud services by using the following command, and then pick the cloud service that you want to migrate. If the VMs in the cloud service are in a virtual network or if they have web or worker roles, the command returns an error message.

    Get-AzureService | ft Servicename

# Get the deployment name for the cloud service. In this example, the service name is My Service. Replace the example service name with your own service name.

    $serviceName = "My Service"
    $deployment = Get-AzureDeployment -ServiceName $serviceName
    $deploymentName = $deployment.DeploymentName

# Prepare the virtual machines in the cloud service for migration. You have two options to choose from.

# Option A. Migrate the VMs to a platform-created virtual network
# First, validate if you can migrate the cloud service using the following commands:

    $validate = Move-AzureService -Validate -ServiceName $serviceName -DeploymentName $deploymentName -CreateNewVirtualNetwork
    $validate.ValidationMessages

# The preceding command displays any warnings and errors that block migration. If validation is successful, then you can move on to the Prepare step:

Move-AzureService -Prepare -ServiceName $serviceName -DeploymentName $deploymentName -CreateNewVirtualNetwork

# Option B. Migrate to an existing virtual network in the Resource Manager deployment model
# This example sets the resource group name to myResourceGroup, the virtual network name to myVirtualNetwork and the subnet name to mySubNet. Replace the names in the example with the names of your own resources.

$existingVnetRGName = "myResourceGroup"
$vnetName = "myVirtualNetwork"
$subnetName = "mySubNet"

# First, validate if you can migrate the virtual network using the following command:

$validate = Move-AzureService -Validate -ServiceName $serviceName -DeploymentName $deploymentName -UseExistingVirtualNetwork  `
-VirtualNetworkResourceGroupName $existingVnetRGName -VirtualNetworkName $vnetName -SubnetName $subnetName
$validate.ValidationMessages

# The preceding command displays any warnings and errors that block migration. If validation is successful, then you can proceed with the following Prepare step:

    Move-AzureService -Prepare -ServiceName $serviceName -DeploymentName $deploymentName -UseExistingVirtualNetwork  `
    -VirtualNetworkResourceGroupName $existingVnetRGName -VirtualNetworkName $vnetName -SubnetName $subnetName

# After the Prepare operation succeeds with either of the preceding options, query the migration state of the VMs. Ensure that they are in the Prepared state.
# This example sets the VM name to myVM. Replace the example name with your own VM name.

    $vmName = "myVM"
    $vm = Get-AzureVM -ServiceName $serviceName -Name $vmName
    $vm.VM.MigrationState

# Check the configuration for the prepared resources by using either PowerShell or the Azure portal. If you are not ready for migration and you want to go back to the old state, use the following command:

    Move-AzureService -Abort -ServiceName $serviceName -DeploymentName $deploymentName

# If the prepared configuration looks good, you can move forward and commit the resources by using the following command:

    Move-AzureService -Commit -ServiceName $serviceName -DeploymentName $deploymentName

# Option 2 - Migrate virtual machines in a virtual network

    $vnetName = "myVnet"
    Move-AzureVirtualNetwork -Validate -VirtualNetworkName $vnetName
    $output = Move-AzureVirtualNetwork -Validate -VirtualNetworkName $vnetName
    $output.ValidationMessages > C:\source\validation-mcag.csv

    Move-AzureVirtualNetwork -Prepare -VirtualNetworkName $vnetName

    # Last change to abort!
    Move-AzureVirtualNetwork -Abort -VirtualNetworkName $vnetName

    Move-AzureVirtualNetwork -Commit -VirtualNetworkName $vnetName

# Migrate a storage account
# Before you migrate the storage account, please perform preceding prerequisite checks: (Migrate classic virtual machines whose disks are stored in the storage account)

# Preceding command returns RoleName and DiskName properties of all the classic VM disks in the storage account. RoleName is the name of the virtual machine to which a disk is attached. If preceding command returns disks then ensure that virtual machines to which these disks are attached are migrated before migrating the storage account.

    $storageAccountName = 'yourStorageAccountName'
    Get-AzureDisk | where-Object {$_.MediaLink.Host.Contains($storageAccountName)} | Select-Object -ExpandProperty AttachedTo -Property `
    DiskName | Format-List -Property RoleName, DiskName

# Delete unattached classic VM disks stored in the storage account
# Find unattached classic VM disks in the storage account using following command:

    $storageAccountName = 'yourStorageAccountName'
    Get-AzureDisk | where-Object {$_.MediaLink.Host.Contains($storageAccountName)} | Where-Object `
    -Property AttachedTo -EQ $null | Format-List -Property DiskName  

# If above command returns disks then delete these disks using following command:

   Remove-AzureDisk -DiskName 'yourDiskName'

# Delete VM images stored in the storage account
# Preceding command returns all the VM images with OS disk stored in the storage account.

   Get-AzureVmImage | Where-Object { $_.OSDiskConfiguration.MediaLink -ne $null -and $_.OSDiskConfiguration.MediaLink.Host.Contains($storageAccountName)`
                           } | Select-Object -Property ImageName, ImageLabel

# Preceding command returns all the VM images with data disks stored in the storage account.

   Get-AzureVmImage | Where-Object {$_.DataDiskConfigurations -ne $null `
    -and ($_.DataDiskConfigurations | Where-Object {$_.MediaLink -ne $null -and $_.MediaLink.Host.Contains($storageAccountName)}).Count -gt 0 `
    } | Select-Object -Property ImageName, ImageLabel

# Delete all the VM images returned by above commands using preceding command:

    Remove-AzureVMImage -ImageName 'yourImageName'

# Validate each storage account for migration by using the following command. In this example, the storage account name is myStorageAccount. Replace the example name with the name of your own storage account.

    $storageAccountName = "myStorageAccount"
    Move-AzureStorageAccount -Validate -StorageAccountName $storageAccountName

# Next step is to Prepare the storage account for migration

    $storageAccountName = "myStorageAccount"
    Move-AzureStorageAccount -Prepare -StorageAccountName $storageAccountName

# Check the configuration for the prepared storage account by using either Azure PowerShell or the Azure portal. If you are not ready for migration and you want to go back to the old state, use the following command:

    Move-AzureStorageAccount -Abort -StorageAccountName $storageAccountName
    
# If the prepared configuration looks good, you can move forward and commit the resources by using the following command:

    Move-AzureStorageAccount -Commit -StorageAccountName $storageAccountName
