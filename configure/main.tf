provider "aws" {
  region = var.region
}

# Calculated local values.
locals {
  vpc_id = data.aws_subnet.selected.vpc_id

  ami_id            = var.ami_id == null ? data.aws_ami.windows2019[0].id : var.ami_id
  count_ami_win2019 = var.ami_id == null ? 1 : 0

  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]

  rdp_port = 3389

  rdp_allowed_cidr = var.rdp_allowed_cidr == null ? local.all_ips[0] : var.rdp_allowed_cidr
}

# Use this data source to retrieve details about a specific VPC subnet.
data "aws_subnet" "selected" {
  id = var.subnet_id
}

# Use this data source to get the ID of a registered AMI for use in other resources.
data "aws_ami" "windows2019" {
  count = local.count_ami_win2019

  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Security group.
resource "aws_security_group" "main" {
  name   = "${var.ops_name}-sg"
  vpc_id = local.vpc_id

  tags = {
    Name        = "${var.ops_name}-sg"
    terraform   = true
    environment = var.environment
  }
}

# Ingress rule.
resource "aws_security_group_rule" "ingress" {
  type              = "ingress"
  description       = "Inbound RDP ${local.rdp_port}"
  security_group_id = aws_security_group.main.id

  from_port   = local.rdp_port
  to_port     = local.rdp_port
  protocol    = local.tcp_protocol
  cidr_blocks = [local.rdp_allowed_cidr]
}

# Egress rule: allow all outbound traffic.
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.main.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}
