output "vpc_id" {
  value = aws_vpc.this[each.key].id
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