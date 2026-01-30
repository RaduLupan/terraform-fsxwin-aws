# Deploy Module

This module creates an [Amazon FSx for Windows File Server](https://docs.aws.amazon.com/fsx/latest/WindowsGuide/what-is.html) with the associated security group.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| aws | ~> 5.0 |

## Usage

```hcl
module "fsx_windows" {
  source = "./deploy"

  region              = "us-east-1"
  active_directory_id = "d-1234567890"
  subnet_ids          = ["subnet-abc123"]
  storage_capacity_gb = 300
  throughput_capacity = 16
  name_tag            = "my-fsx-windows"
  environment         = "dev"
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| region | AWS region | `string` | Yes |
| active_directory_id | AWS Managed AD directory ID | `string` | Yes |
| subnet_ids | Subnet IDs for FSx endpoints | `list(string)` | Yes |
| storage_capacity_gb | Storage capacity in GiB | `number` | Yes |
| throughput_capacity | Throughput in MB/s (8-2048) | `number` | Yes |
| deployment_type | SINGLE_AZ_1, SINGLE_AZ_2, or MULTI_AZ_1 | `string` | No |
| storage_type | SSD or HDD | `string` | No |
| security_group_id | Existing security group ID | `string` | No |
| kms_key_id | KMS key ARN for encryption | `string` | No |

## Outputs

| Name | Description |
|------|-------------|
| id | FSx file system ID |
| arn | FSx file system ARN |
| dns_name | DNS name for mounting |
| remote_administration_endpoint | PowerShell remoting endpoint |
| network_interface_ids | ENI IDs for the file system |
| vpc_id | VPC ID where FSx is deployed |
