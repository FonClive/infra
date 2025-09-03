include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/servers/"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  environments = "dev"
  key_name        = "dev-key"
  public_key_path = "~/.ssh/dev-key.pub"
  ec2_parameters = {
    instance_count = 3
    instance_type  = "t3.micro"
    subnet_ids     = dependency.vpc.outputs.public_subnet_ids
    
    tags = {
      role = "frontend"
    }
  }
  
  security_group_ids = [
    dependency.vpc.outputs.sg_ids["ssh"],
    dependency.vpc.outputs.sg_ids["web"]
  ]
}