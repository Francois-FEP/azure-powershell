# Press Shift-F10 to open command prompt.
# Run PowerShell by simply typing PowerShell <Enter> into the command prompt window. This will convert the command prompt to a PowerShell session with Administrator privilege.
# Run the following command: 
Set-ExecutionPolicy Bypass 
#to enable scripts.  
# If a dialog appears asking [Y], [A], [N], [L], [S], [?], Select Yes for All [A].
# From the PowerShell session, copy/paste the following commands. Press <Enter> after each command.


$AccountName ="sysadmin"
# Note: If you’re performing this demo on a locally hosted VM, use a local administrative user name instead of “demo user”.
$Password = ConvertTo-SecureString "P@ssw0rd!!!!" -AsPlainText -Force
# Note: Use the password provided to you from your VM Environments that you used to log into the Demo User account on the VM Host. 
# Note: If you’re performing this demo on a locally hosted VM please use the local administrative user’s password instead of the demo user password.
$cred = New-Object System.Management.Automation.PSCredential($AccountName, $Password)
New-PSDrive –Name “Q” –PSProvider FileSystem –Root "\\192.168.0.76\Share" -Credential $cred –Persist
# Note: If you’re performing this demo on a locally hosted VM please use the IP address of the host machine here.

Install-Script Get-WindowsAutoPilotInfo
# Answer Y to all three prompts that follow this command.

Get-WindowsAutoPilotInfo.ps1 -OutputFile Q:\WindowsAutoPilotInfo.csv


$AccountName ="autopilot"
$Password = ConvertTo-SecureString "P@ssw0rd!!!!" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential($AccountName, $Password)
New-PSDrive –Name “Q” –PSProvider FileSystem –Root "\\192.168.0.76\Share" -Credential $cred –Persist
Install-Script Get-WindowsAutoPilotInfo
Get-WindowsAutoPilotInfo.ps1 -OutputFile Q:\WindowsAutoPilotInfo.csv