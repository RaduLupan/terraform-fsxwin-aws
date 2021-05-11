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
}

