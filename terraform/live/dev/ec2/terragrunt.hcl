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

  ec2_parameters = {
    instance_count = 3
    instance_type  = "t3.micro"
    subnet_ids     = dependency.vpc.outputs.public_subnet_ids
    tags = {
      role = "frontend"
    }
  }

}