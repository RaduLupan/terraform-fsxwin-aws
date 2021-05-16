param (
    [string]$FileSystemId,
    [string]$FileSystemAlias
)

$FileSystemDnsName=(Get-FSXFileSystem -FileSystemId $FileSystemId).DNSName

# Find SPNs for original file system's AD computer object.
SetSPN /Q ("HOST/" + $FileSystemAlias)
SetSPN /Q ("HOST/" + $FileSystemAlias.Split(".")[0])

# Delete SPNs for original file system's AD computer object.
$FileSystemHost = (Resolve-DnsName $FileSystemDnsName | Where-Object Type -eq 'A')[0].Name.Split(".")[0]
$FSxAdComputer = (Get-AdComputer -Identity $FileSystemHost)

SetSPN /D ("HOST/" + $FileSystemAlias) $FSxAdComputer.Name
SetSPN /D ("HOST/" + $FileSystemAlias.Split(".")[0]) $FSxAdComputer.Name

# Set SPNs for FSx file system AD computer object.
Set-AdComputer -Identity $FSxAdComputer -Add @{"msDS-AdditionalDnsHostname"="$FileSystemAlias"}
SetSpn /S ("HOST/" + $FileSystemAlias.Split('.')[0]) $FSxAdComputer.Name
SetSpn /S ("HOST/" + $FileSystemAlias) $FSxAdComputer.Name

# Verify SPNs on FSx file system AD computer object.
SetSpn /L $FSxAdComputer.Name

# Create/update DNS CNAME for your Amazon FSx file system.
$AliasHost=$FileSystemAlias.Split('.')[0]
$ZoneName=((Get-WmiObject Win32_ComputerSystem).Domain)
$DnsServerComputerName = (Resolve-DnsName $ZoneName -Type NS | Where-Object Type -eq 'A' | Select-Object -ExpandProperty Name)[0]

# Delete CNAME if already exists and then add custom CNAME.
Get-DnsServerResourceRecord -ZoneName $ZoneName -RRType CName -ComputerName $DnsServerComputerName | 
Where-Object {$_.HostName -eq $AliasHost} | 
Remove-DnsServerResourceRecord -ZoneName $ZoneName -ComputerName $DnsServerComputerName -Force

Add-DnsServerResourceRecordCName -Name $AliasHost -ComputerName $DnsServerComputerName -HostNameAlias $FileSystemDnsName -ZoneName $ZoneName

