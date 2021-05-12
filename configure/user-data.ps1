<powershell>
# Install AWS CLI v2
$cmd="msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /quiet"
Invoke-Expression -Command $cmd

# Remote Server Administration Tools for AD PowerShell and DNS
Install-WindowsFeature RSAT-AD-PowerShell, RSAT-DNS-Server
 
Rename-Computer -NewName "${computer_name}" -Force
</powershell>