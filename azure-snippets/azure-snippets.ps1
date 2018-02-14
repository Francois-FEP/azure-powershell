# Force shutdown classic VM

Stop-AzureVM -ServiceName MGADFSServices -Name ADFS-AZU-02 -Force

# Start classic VM

Start-AzureVM -ServiceName MGADFSServices -Name ADFS-AZU-02 

# NOTE: Try redeploying VM or resizing if issues are had when starting.