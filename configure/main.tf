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

  common_tags = {
    terraform   = true
    environment = var.environment
  }

  # Rendered templates using templatefile() function.
  ec2_role_trust_policy = file("${path.module}/ec2-role-trust.json.tpl")
  ec2_role_policy       = file("${path.module}/ec2-role-policy.json.tpl")
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

# IAM instance role
resource "aws_iam_role" "main" {
  name = "${var.ops_name}-role"
  path = "/"

  assume_role_policy = local.ec2_role_trust_policy
  tags               = local.common_tags
}

# IAM instance policy.
resource "aws_iam_role_policy" "main" {
  name = "${var.ops_name}-policy"
  role = aws_iam_role.main.id

  policy = local.ec2_role_policy
}

# IAM instance profile.
resource "aws_iam_instance_profile" "main" {
  name = "${var.ops_name}-profile"
  role = aws_iam_role.main.name
}

# EC2 instance for operations.
resource "aws_instance" "ops" {
  ami           = local.ami_id
  instance_type = var.ops_instance_type

  key_name               = var.key_name
  monitoring             = true
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.main.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = 150
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user-data.ps1", {
    region            = var.region
    s3_bucket         = aws_s3_bucket.scripts.id
    computer_name     = var.ops_name
    file_system_id    = var.file_system_id
    file_system_alias = var.file_system_alias
  })

  iam_instance_profile = aws_iam_instance_profile.main.name

  tags = {
    Name        = var.ops_name
    terraform   = true
    environment = var.environment
  }
}

# Create the SSM document if var.ssm_document is null.
resource "aws_ssm_document" "main" {
  count = var.ssm_document == null ? 1 : 0

  name          = "${var.ad_domain_fqdn}-domain-join"
  document_type = "Command"

  content = templatefile("${path.module}/ssm-document.json.tpl", {
    ad_id          = var.ad_id
    ad_domain_fqdn = var.ad_domain_fqdn
    ad_dns_ip1     = var.ad_dns_ips[0]
    ad_dns_ip2     = var.ad_dns_ips[1]
  })
}

# Create the SSM association if var.ssm_document is null.
resource "aws_ssm_association" "main" {
  count = var.ssm_document == null ? 1 : 0

  name = aws_ssm_document.main[0].name

  targets {
    key    = "InstanceIds"
    values = [aws_instance.ops.id]
  }
}
# Elastic IP.
resource "aws_eip" "main" {
  domain = "vpc"
}

# Elastic IP association.
resource "aws_eip_association" "main" {
  instance_id   = aws_instance.ops.id
  allocation_id = aws_eip.main.id
}

# S3 bucket for scripts.
resource "aws_s3_bucket" "scripts" {
  bucket = "${var.ops_name}-scripts-${var.region}"

  force_destroy = true

  tags = local.common_tags
}

# S3 bucket versioning (recommended).
resource "aws_s3_bucket_versioning" "scripts" {
  bucket = aws_s3_bucket.scripts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block (security best practice).
resource "aws_s3_bucket_public_access_block" "scripts" {
  bucket = aws_s3_bucket.scripts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload PowerShell script to S3.
resource "aws_s3_object" "configure_fsx_ps1_upload" {
  bucket = aws_s3_bucket.scripts.id
  key    = "configure-fsx.ps1"
  source = "./configure-fsx.ps1"
  etag   = filemd5("./configure-fsx.ps1")
}
