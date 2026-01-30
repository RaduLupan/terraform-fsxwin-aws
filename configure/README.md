# Configure Module

This module deploys an AD domain-joined Windows EC2 instance for administering the FSx file system.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| aws | ~> 5.0 |

## Features

- **Windows Server 2019** EC2 instance (or custom AMI)
- **Automatic domain join** via SSM document
- **Elastic IP** for consistent public access
- **S3 bucket** for configuration scripts
- **Security group** with RDP access

## Usage

```hcl
module "fsx_ops" {
  source = "./configure"

  region            = "us-east-1"
  key_name          = "my-key-pair"
  subnet_id         = "subnet-abc123"
  ad_id             = "d-1234567890"
  ad_dns_ips        = ["10.0.0.10", "10.0.1.10"]
  ad_domain_fqdn    = "corp.example.com"
  file_system_id    = "fs-0123456789abcdef"
  file_system_alias = "fsx.corp.example.com"
  rdp_allowed_cidr  = "203.0.113.0/24"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| region | AWS region | `string` | Yes |
| key_name | EC2 key pair name | `string` | Yes |
| subnet_id | Subnet ID for EC2 instance | `string` | Yes |
| ad_id | AWS Managed AD directory ID | `string` | Yes |
| ad_dns_ips | AD DNS server IPs | `list(string)` | Yes |
| ad_domain_fqdn | AD domain FQDN | `string` | Yes |
| file_system_id | FSx file system ID | `string` | Yes |
| file_system_alias | DNS alias for FSx | `string` | No |
| ops_instance_type | EC2 instance type | `string` | No |
| ami_id | Custom AMI ID | `string` | No |
| rdp_allowed_cidr | CIDR for RDP access | `string` | No |
| ops_name | Computer name for instance | `string` | No |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | EC2 instance ID |
| instance_public_ip | Elastic IP address |
| instance_private_ip | Private IP address |
| security_group_id | Security group ID |
| s3_bucket_name | S3 bucket for scripts |
| ssm_document_name | SSM document for domain join |

## Post-Deployment Steps

1. **Wait for domain join** - The instance will reboot after joining the domain
2. **RDP to the instance** - Use the Elastic IP with domain credentials
3. **Run configuration script** (optional):
   ```powershell
   C:\scripts\configure-fsx.ps1 -FileSystemId "fs-xxx" -FileSystemAlias "fsx.corp.example.com"
   ```

## Notes

- The `configure-fsx.ps1` script adds the DNS alias and Service Principal Names (SPNs) for Kerberos authentication
- For remote FSx administration, use: `Enter-PSSession -ComputerName <remote_admin_endpoint> -ConfigurationName FsxRemoteAdmin`
