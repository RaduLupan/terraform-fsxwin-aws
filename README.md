# Terraform AWS FSx for Windows File Server

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-blueviolet)](https://www.terraform.io/)
[![AWS Provider](https://img.shields.io/badge/AWS%20Provider-~%3E5.0-orange)](https://registry.terraform.io/providers/hashicorp/aws/latest)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

Deploy a fully functional [Amazon FSx for Windows File Server](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) with an optional Windows EC2 management instance—all automated with Terraform.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                           AWS VPC                               │
│  ┌───────────────────────┐    ┌───────────────────────────────┐ │
│  │    Private Subnet     │    │        Private Subnet         │ │
│  │                       │    │                               │ │
│  │  ┌─────────────────┐  │    │  ┌─────────────────────────┐  │ │
│  │  │   FSx Windows   │  │    │  │   Windows EC2 (OPS)     │  │ │
│  │  │   File Server   │◄─┼────┼──│   - Domain Joined       │  │ │
│  │  │                 │  │    │  │   - FSx Admin Tools     │  │ │
│  │  └────────┬────────┘  │    │  └─────────────────────────┘  │ │
│  │           │           │    │                               │ │
│  └───────────┼───────────┘    └───────────────────────────────┘ │
│              │                                                  │
│              ▼                                                  │
│  ┌───────────────────────┐                                      │
│  │   AWS Managed AD      │                                      │
│  │   (Directory Service) │                                      │
│  └───────────────────────┘                                      │
└─────────────────────────────────────────────────────────────────┘
```

## 📦 Modules

| Module | Description |
|--------|-------------|
| [`deploy/`](./deploy/) | Creates the FSx for Windows file system with security groups |
| [`configure/`](./configure/) | Deploys a domain-joined Windows EC2 instance for FSx administration |

## ✅ Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) >= 1.5
- AWS account with appropriate permissions
- Existing AWS Managed Microsoft AD (or self-managed AD)
- VPC with private subnets

## 🚀 Quick Start

### 1. Configure AWS Credentials

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"
```

Or configure via AWS CLI profile:
```bash
aws configure --profile myprofile
export AWS_PROFILE=myprofile
```

### 2. Clone the Repository

```bash
git clone https://github.com/RaduLupan/terraform-fsxwin-aws.git
cd terraform-fsxwin-aws
```

### 3. Deploy FSx for Windows File Server

```bash
cd deploy

# Create terraform.tfvars with your values
cat > terraform.tfvars <<EOF
region              = "us-east-1"
active_directory_id = "d-1234567890"
subnet_ids          = ["subnet-abc123", "subnet-def456"]
storage_capacity_gb = 300
throughput_capacity = 16
name_tag            = "my-fsx-windows"
environment         = "dev"
EOF

terraform init
terraform plan
terraform apply
```

### 4. Deploy Management Instance (Optional)

```bash
cd ../configure

# Create terraform.tfvars
cat > terraform.tfvars <<EOF
region            = "us-east-1"
key_name          = "my-key-pair"
subnet_id         = "subnet-abc123"
ad_id             = "d-1234567890"
ad_dns_ips        = ["10.0.0.10", "10.0.1.10"]
ad_domain_fqdn    = "corp.example.com"
file_system_id    = "fs-0123456789abcdef"  # From deploy output
EOF

terraform init
terraform plan
terraform apply
```

## 📋 Input Variables

### Deploy Module

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `region` | AWS region | `string` | ✅ |
| `active_directory_id` | AWS Managed AD directory ID | `string` | ✅ |
| `subnet_ids` | Subnet IDs for FSx endpoints | `list(string)` | ✅ |
| `storage_capacity_gb` | Storage capacity in GiB (min 32) | `number` | ✅ |
| `throughput_capacity` | Throughput in MB/s (8-2048) | `number` | ✅ |
| `deployment_type` | `SINGLE_AZ_1`, `SINGLE_AZ_2`, or `MULTI_AZ_1` | `string` | ❌ |
| `storage_type` | `SSD` or `HDD` | `string` | ❌ |

### Configure Module

| Variable | Description | Type | Required |
|----------|-------------|------|----------|
| `region` | AWS region | `string` | ✅ |
| `key_name` | EC2 key pair name | `string` | ✅ |
| `subnet_id` | Subnet ID for EC2 instance | `string` | ✅ |
| `ad_id` | AWS Managed AD directory ID | `string` | ✅ |
| `ad_dns_ips` | AD DNS server IPs | `list(string)` | ✅ |
| `ad_domain_fqdn` | AD domain FQDN | `string` | ✅ |
| `file_system_id` | FSx file system ID | `string` | ✅ |
| `ops_instance_type` | EC2 instance type | `string` | ❌ |
| `rdp_allowed_cidr` | CIDR for RDP access | `string` | ❌ |

## 📤 Outputs

| Output | Description |
|--------|-------------|
| `id` | FSx file system ID |
| `arn` | FSx file system ARN |
| `dns_name` | DNS name for mounting (e.g., `fs-xxx.corp.example.com`) |
| `remote_administration_endpoint` | PowerShell remoting endpoint |
| `network_interface_ids` | ENI IDs for the file system |

## 💡 Usage Examples

### Mount FSx on Windows

```powershell
# Map network drive
net use Z: \\fs-0123456789abcdef.corp.example.com\share

# Or using DNS alias
net use Z: \\fsx.corp.example.com\share
```

### Remote PowerShell Administration

```powershell
# Connect to FSx for remote administration
Enter-PSSession -ComputerName amznfsxxxxxxx.corp.example.com -ConfigurationName FsxRemoteAdmin
```

## 🔒 Security Features

- **Security Groups**: Automatically configured for SMB (445) and WinRM (5985)
- **S3 Bucket**: Private with public access blocked and versioning enabled
- **Encryption**: KMS encryption at rest (optional custom key)
- **Domain Integration**: Seamless AD authentication via AWS Managed AD

## 📚 Resources

- [Amazon FSx for Windows File Server Documentation](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html)
- [Best Practices for Administering Amazon FSx](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/admin-best-practices-fsxw.html)
- [Terraform AWS Provider - FSx Windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/fsx_windows_file_system)

## 📝 License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details.

---

**Author:** [Radu Lupan](https://github.com/RaduLupan)  
**Last Updated:** January 2026
