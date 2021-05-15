<powershell>
$FileSystemId="${file_system_id}"
$FileSystemAlias="${file_system_alias}"

# Install AWS CLI v2.
$cmd="msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi /quiet"
Invoke-Expression -Command $cmd

# Remote Server Administration Tools for AD PowerShell and DNS.
Install-WindowsFeature RSAT-AD-PowerShell, RSAT-DNS-Server

# Associate alias to existing FSx file system. 
$env:Path+=";C:\Program Files\Amazon\AWSCLIV2\"

if ($FileSystemAlias -ne $null) {
    $cmd="aws fsx associate-file-system-aliases --file-system-id $FileSystemId --aliases $FileSystemAlias"
    Invoke-Expression -Command $cmd
}

Rename-Computer -NewName "${computer_name}" -Force
</powershell>