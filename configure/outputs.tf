output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ops.id
}

output "instance_public_ip" {
  description = "The Elastic IP address associated with the instance"
  value       = aws_eip.main.public_ip
}

output "instance_private_ip" {
  description = "The private IP address of the instance"
  value       = aws_instance.ops.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.main.id
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket containing scripts"
  value       = aws_s3_bucket.scripts.id
}

output "ssm_document_name" {
  description = "The name of the SSM document for domain join"
  value       = var.ssm_document == null ? aws_ssm_document.main[0].name : var.ssm_document
}
