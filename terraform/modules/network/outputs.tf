output "vpc_id" {
  description = "Map of VPC IDs"
  value       = { for k, v in aws_vpc.this : k => v.id }
}

# For all subnets
output "subnet_ids" {
  value = [for s in aws_subnet.this : s.id]
}

# Public subnets (filtered by tag or name)
output "public_subnet_ids" {
  value = [
    for s in aws_subnet.this : s.id
    if try(s.tags["tier"], "") == "frontend"
  ]
}


# Private subnets (filtered by tag or name)
output "private_subnet_ids" {
  value = [
    for s in aws_subnet.this : s.id
    if try(s.tags["tier"], "") == "backend"
  ]
}

output "sg_ids" {
  description = "Map of created security groups"
  value       = { for k, sg in aws_security_group.this : k => sg.id }
}