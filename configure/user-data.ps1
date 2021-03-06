<powershell>
$Region="${region}"
$S3Bucket="${s3_bucket}"
$ComputerName="${computer_name}"
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

if (! (Test-Path -Path "C:\scripts")) {
    New-Item -Path "C:\scripts" -ItemType Container | Out-Null
}

# Download the Powershell script from S3 buket in the C:\scripts folder.
if ($S3Bucket -ne $null) {
    Read-S3Object -BucketName $S3Bucket -Key "configure-fsx.ps1" -File "C:\scripts\configure-fsx.ps1" -Region $Region
}

Rename-Computer -NewName $ComputerName -Force
</powershell>