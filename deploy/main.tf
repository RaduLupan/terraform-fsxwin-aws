provider "aws" {
  region = var.region
}

# Calculated local values.
locals {
  vpc_id = data.aws_subnet.selected.vpc_id

  security_group_id = var.security_group_id == null ? aws_security_group.main[0].id : var.security_group_id

  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  udp_protocol = "udp"
  all_ips      = ["0.0.0.0/0"]

  # Allow ingress SMB and WinRM from the VPC CIDR.
  ingress_tcp_ports = {
    "445"  = data.aws_vpc.selected.cidr_block
    "5985" = data.aws_vpc.selected.cidr_block
  }

  # FSx requires these ports for Active Directory integration
  # Reference: https://docs.aws.amazon.com/fsx/latest/WindowsGuide/aws-ad-integration-fsxW.html
  egress_tcp_ports = [53, 88, 135, 389, 445, 464, 636, 3268, 3269]
  egress_udp_ports = [53, 88, 123, 389, 464]
}

# Use this data source to retrieve details about a specific VPC subnet.
data "aws_subnet" "selected" {
  id = var.subnet_ids[0]
}

# Use this data source to retrieve details about a specific VPC.
data "aws_vpc" "selected" {
  id = local.vpc_id
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

# Ingress rules.
resource "aws_security_group_rule" "ingress_tcp" {
  for_each = local.ingress_tcp_ports

  type              = "ingress"
  description       = "Inbound TCP ${each.key}"
  security_group_id = aws_security_group.main[0].id

  from_port   = each.key
  to_port     = each.key
  protocol    = local.tcp_protocol
  cidr_blocks = [each.value]
}

# Egress TCP rules for Active Directory integration.
resource "aws_security_group_rule" "egress_tcp" {
  for_each = toset([for p in local.egress_tcp_ports : tostring(p)])

  type              = "egress"
  description       = "Outbound TCP ${each.key} for AD"
  security_group_id = aws_security_group.main[0].id

  from_port   = tonumber(each.key)
  to_port     = tonumber(each.key)
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

# Egress UDP rules for Active Directory integration.
resource "aws_security_group_rule" "egress_udp" {
  for_each = toset([for p in local.egress_udp_ports : tostring(p)])

  type              = "egress"
  description       = "Outbound UDP ${each.key} for AD"
  security_group_id = aws_security_group.main[0].id

  from_port   = tonumber(each.key)
  to_port     = tonumber(each.key)
  protocol    = local.udp_protocol
  cidr_blocks = local.all_ips
}

# Egress rule: allow all other outbound traffic.
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.main[0].id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

# FSx File System for Windows.
resource "aws_fsx_windows_file_system" "main" {
  active_directory_id = var.active_directory_id

  deployment_type     = var.deployment_type
  subnet_ids          = var.subnet_ids
  preferred_subnet_id = var.subnet_ids[0]
  security_group_ids  = [local.security_group_id]

  storage_capacity    = var.storage_capacity_gb
  throughput_capacity = var.throughput_capacity

  tags = {
    Name        = var.name_tag
    terraform   = true
    environment = var.environment
  }
}