#----------------------------------------------------------------------------
# REQUIRED PARAMETERS: You must provide a value for each of these parameters.
#----------------------------------------------------------------------------

variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair that allows to securely connect to the instance after launch"
  type        = string
}

variable "subnet_id" {
  description = "The  ID of a subnet in the VPC where the OPS instance will be deployed"
  type        = string
}

variable "ad_id" {
  description = "The ID of the AWS Microsoft AD directory"
  type        = string
}

variable "ad_dns_ips" {
  description = "The IPs of the DNS servers for the AD domain"
  type        = list(string)
}

variable "ad_domain_fqdn" {
  description = "The  fully qualified domain name of the AD domain, i.e. example.com"
  type        = string
}

variable "file_system_id" {
  description = "Identifier of the FSx file system for Windows to configured"
  type        = string
}

#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "dev"
}

variable "ops_instance_type" {
  description = "The EC2 instance type for the OPS instance"
  type        = string
  default     = "t3.small"
}

variable "ami_id" {
  description = "The ID of the AWS EC2 AMI to use (if null the latest Windows Server 2019 is selected)"
  type        = string
  default     = null
}

variable "rdp_allowed_cidr" {
  description = "The allowed CIDR IP range for RDP access to the OPS instance"
  type        = string
  default     = null
}

variable "ops_name" {
  description = "The computer name of the OPS instance"
  type        = string
  default     = "ops01"
}

variable "ssm_document" {
  description = "The name of an SSM document that joins computers to AD domain (if null new SSM documnt will be created)"
  type        = string
  default     = null
}

variable "file_system_alias" {
  description = "The alias to be added to the FSx file system for Windows"
  type        = string
  default     = null
}