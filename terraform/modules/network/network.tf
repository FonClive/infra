#################################
# VPC
#################################
resource "aws_vpc" "this" {
  for_each = var.vpc_parameters

  cidr_block           = each.value.cidr_block
  enable_dns_support   = lookup(each.value, "enable_dns_support", true)
  enable_dns_hostnames = lookup(each.value, "enable_dns_hostnames", true)

  tags = merge(
    {
      Name        = each.key
      Environment = var.environments
    },
    lookup(each.value, "tags", {})
  )
}

#################################
# Subnets
#################################
resource "aws_subnet" "this" {
  for_each = var.subnet_parameters

  vpc_id                  = aws_vpc.this[each.value.vpc_name].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = each.value.name
      Environment = var.environments
    },
    lookup(each.value, "tags", {})
  )
}

#################################
# Internet Gateway
#################################
resource "aws_internet_gateway" "this" {
  for_each = var.igw_parameters

  vpc_id = aws_vpc.this[each.value.vpc_name].id

  tags = merge(
    {
      Name        = each.key
      Environment = var.environments
    },
    lookup(each.value, "tags", {})
  )
}

#################################
# Route Tables + Routes
#################################
resource "aws_route_table" "this" {
  for_each = var.rt_parameters

  vpc_id = aws_vpc.this[var.subnet_parameters[each.value.subnet_name].vpc_name].id

  tags = merge(
    {
      Name        = each.key
      Environment = var.environments
    },
    lookup(each.value, "tags", {})
  )
}

resource "aws_route" "this" {
  for_each = {
    for rt_key, rt in var.rt_parameters : rt_key => rt
    if length(rt.routes) > 0
  }

  route_table_id         = aws_route_table.this[each.key].id
  destination_cidr_block = each.value.routes[0].destination_cidr_block

  gateway_id = each.value.routes[0].use_igw ? aws_internet_gateway.this[each.value.routes[0].gateway_id].id : each.value.routes[0].gateway_id
}

resource "aws_route_table_association" "this" {
  for_each = var.rt_parameters

  subnet_id      = aws_subnet.this[each.value.subnet_name].id
  route_table_id = aws_route_table.this[each.key].id
}

resource "aws_security_group" "this" {
  for_each = var.sg_parameters

  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.this[each.value.vpc_name].id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      description = lookup(ingress.value, "description", "ingress rule")
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      description = lookup(egress.value, "description", "egress rule")
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
