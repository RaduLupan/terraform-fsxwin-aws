output "arn" {
  description = "The Amazon Resource Name of the file system"
  value       = aws_fsx_windows_file_system.main.arn
}

output "dns_name" {
  description = "DNS name for the file system"
  value       = aws_fsx_windows_file_system.main.dns_name
}

output "remote_administration_endpoint" {
  description = "Endpoint for performing admin tasks on the file system using Amazon FSx Remote PowerShell"
  value       = aws_fsx_windows_file_system.main.remote_administration_endpoint
}

output "network_interface_ids" {
  description = "Set of Elastic Network Interface identifiers from which the file system is accessible"
  value       = aws_fsx_windows_file_system.main.network_interface_ids
}

output "vpc_id" {
  description = "Identifier of the Virtual Private Cloud for the file system"
  value       = aws_fsx_windows_file_system.main.vpc_id
}