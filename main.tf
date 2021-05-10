provider "aws" {
  region = var.region
}

# Calculated local values.
locals {
  vpc_id = data.aws_subnet.selected.vpc_id

  common_tags = {
    terraform   = true
    environment = var.environment
  }
}

# Use this data source to retrieve details about a specific VPC subnet.
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

resource "aws_fsx_windows_file_system" "main" {
  active_directory_id = var.active_directory_id
  storage_capacity    = var.storage_capacity_gb
  deployment_type     = var.deployment_type
  subnet_ids          = var.subnet_ids
  throughput_capacity = var.throughput_capacity
}