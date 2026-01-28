output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "Public Subnet ID"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "Security Group ID"
  value       = aws_security_group.app.id
}

output "ec2_instance_ids" {
  description = "EC2 Instance IDs"
  value       = aws_instance.app[*].id
}

output "ec2_instance_ip" {
  description = "EC2 Instance IP addresses"
  value       = aws_instance.app[*].private_ip_address
}

output "ec2_instance_public_ip" {
  description = "EC2 Instance Public IP addresses"
  value       = aws_eip.app[*].public_ip
}

output "application_url" {
  description = "URL to access the application"
  value       = length(aws_eip.app) > 0 ? "http://${aws_eip.app[0].public_ip}" : "EC2 instances created but no EIP assigned"
}

output "cloudwatch_log_group" {
  description = "CloudWatch Log Group for application"
  value       = aws_cloudwatch_log_group.app.name
}
