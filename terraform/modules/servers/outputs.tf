output "ec2_public_ips" {
  value = [for instance in aws_instance.this : instance.public_ip]
}

output "ec2_private_ips" {
  value = [for instance in aws_instance.this : instance.private_ip]
}

output "ec2" {
  value = [for instance in aws_instance.this : instance.id]
}




