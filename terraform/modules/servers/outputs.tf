output "ec2_public_ips" {
  description = "Public IP addresses of EC2 instances"
  value       = [for instance in aws_instance.this : instance.public_ip]
}

output "ec2_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = [for instance in aws_instance.this : instance.private_ip]
}

output "ec2_instance_ids" {
  description = "Instance IDs for SSM connectivity"
  value       = [for instance in aws_instance.this : instance.id]
}

output "ssm_connection_test_command" {
  description = "Command to test SSM connectivity"
  value       = "aws ssm describe-instance-information --filters 'Key=InstanceIds,Values=${join(",", [for instance in aws_instance.this : instance.id])}' --query 'InstanceInformationList[*].[InstanceId,PingStatus]' --output table"
}

output "iam_role_name" {
  description = "IAM role attached to EC2 instances for SSM"
  value       = aws_iam_role.ec2_ssm_role.name
}

output "iam_instance_profile_arn" {
  description = "IAM instance profile ARN"
  value       = aws_iam_instance_profile.ec2_profile.arn
}




