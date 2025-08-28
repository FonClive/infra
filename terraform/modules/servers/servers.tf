
#################################
# EC2 Instances
#################################
resource "aws_instance" "this" {
  count = var.ec2_parameters.instance_count

  ami           = "ami-0360c520857e3138f"
  instance_type = var.ec2_parameters.instance_type

  # distribute evenly across subnets
  subnet_id = element(var.ec2_parameters.subnet_ids, count.index % length(var.ec2_parameters.subnet_ids))

  tags = merge(
    {
      Name        = "instance-${count.index}"
      Environment = var.environments
    },
    lookup(var.ec2_parameters, "tags", {})
  )
}

