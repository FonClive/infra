resource "aws_key_pair" "this" {
  key_name   = var.key_name
  public_key = file(pathexpand(var.public_key_path))
}


#################################
# EC2 Instances
#################################
resource "aws_instance" "this" {
  count = var.ec2_parameters.instance_count

  ami          = var.ec2_parameters. ami_id
  instance_type = var.ec2_parameters.instance_type

  # distribute evenly across subnets
  subnet_id = element(var.ec2_parameters.subnet_ids, count.index % length(var.ec2_parameters.subnet_ids))
  
  key_name = var.key_name 


  vpc_security_group_ids = var.security_group_ids
  
  tags = merge(
    {
      Name        = "instance-${count.index}"
      Environment = var.environments
    },
    lookup(var.ec2_parameters, "tags", {})
  )
}

