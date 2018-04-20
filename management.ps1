# List Azure Modules and versions 
Get-Module -ListAvailable -Name AzureRM -Refresh

# Uninstall specific AzureRM version 
Get-InstalledModule -Name "AzureRM" -RequiredVersion 5.6.0 | Uninstall-Module

