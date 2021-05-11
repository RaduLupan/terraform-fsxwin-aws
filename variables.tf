#----------------------------------------------------------------------------
# REQUIRED PARAMETERS: You must provide a value for each of these parameters.
#----------------------------------------------------------------------------

variable "region" {
  description = "AWS region"
  type        = string
}

variable "active_directory_id" {
  description = "The ID of the AWS Microsoft AD directory"
  type        = string
}

variable "subnet_ids" {
  description = "A list of IDs for the subnets that the file system will be accessible from"
  type        = list(string)
}

variable "storage_capacity_gb" {
  description = "Storage capacity (GiB) of the file system"
  type        = number
}

variable "throughput_capacity" {
  description = "Throughput (megabytes per second) of the file system in power of 2 increments (minimum of 8 and maximum of 2048)"
  type        = number
}
#---------------------------------------------------------------
# OPTIONAL PARAMETERS: These parameters have resonable defaults.
#---------------------------------------------------------------

variable "environment" {
  description = "Environment i.e. dev, test, stage, prod"
  type        = string
  default     = "dev"
}

variable "kms_key_id" {
  description = "ARN for the KMS key to encrypt the file system at rest (defaults to an AWS managed KMS key)"
  type        = string
  default     = null
}

variable "security_group_id" {
  description = "The ID for the security group that applies to the specified network interfaces created for file system access"
  type        = string
  default     = null
}

variable "deployment_type" {
  description = "Specifies the file system deployment type, valid values are MULTI_AZ_1, SINGLE_AZ_1 and SINGLE_AZ_2 (defaults to SINGLE_AZ_1)"
  type        = string
  default     = "SINGLE_AZ_1"
}

variable "storage_type" {
  description = "Specifies the storage type, valid values are SSD and HDD (defaults to SSD)"
  type        = string
  default     = "SSD"
}