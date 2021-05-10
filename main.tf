provider "aws" {
  region = var.region
}

# Calculated local values.
locals {
  vpc_id = data.aws_subnet.selected.vpc_id

  security_group_id = var.security_group_id == null ? aws_security_group.main[0].id : var.security_group_id

  common_tags = {
    terraform   = true
    environment = var.environment
  }
}

# Use this data source to retrieve details about a specific VPC subnet.
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

# Deploy security group if var.security_group_ids == null.
resource "aws_security_group" "main" {
  count = var.security_group_id == null ? 1 : 0

  name   = "fsxwin-file-system-sg"
  vpc_id = local.vpc_id

  tags = {
    Name        = "fsxwin-file-system-sg"
    terraform   = true
    environment = var.environment
  }
}

# FSx File System for Windows.
resource "aws_fsx_windows_file_system" "main" {
  active_directory_id = var.active_directory_id
  
  deployment_type     = var.deployment_type
  subnet_ids          = var.subnet_ids
  security_group_ids  = [local.security_group_id]

  storage_capacity    = var.storage_capacity_gb
  throughput_capacity = var.throughput_capacity
}