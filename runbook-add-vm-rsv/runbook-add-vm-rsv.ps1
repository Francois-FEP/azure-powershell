# Backup-VM Runbook
# Need to add modules at the start of the PowerShell script - AzureRM.profile, AzureRM.RecoveryServices and AzureRM.RecoveryServices.Backup
    Param(
    [object] $Webhookdata,
    [Parameter(Mandatory=$false)]
    [String]
   $RecoveryServicesVault  = "rsv-techkb-001",
    [parameter(Mandatory=$false)]
    [String] 
    $policyName = "DefaultPolicy"
    )

    # Takes Subject string and splits into an array
    # Array is used to populate VMName and ResourceGroupName variables
    $Subject = $Webhookdata.RequestBody
    $resArray = $Subject.split("/")
    $VMName = $resArray[-1]
    $ResourceGroupName = $resArray[-5]
    $connectionName = "AzureRunAsConnection";

    try
    {
        # Get the connection "AzureRunAsConnection"
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName        
 
        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {

        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }

    # Get Recovery Services Vault details and add VM to the backup using the defined policy"
    Get-AzureRmRecoveryServicesVault -Name $RecoveryServicesVault | Set-AzureRmRecoveryServicesVaultContext
    $policy = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyName
    Enable-AzureRmRecoveryServicesBackupProtection `
        -ResourceGroupName $ResourceGroupName `
        -Name $VMName `
        -Policy $policy
