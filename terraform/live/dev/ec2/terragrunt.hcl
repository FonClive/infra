include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/servers/"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "s3_ssm_logs" {
  config_path = "../s3-ssm-logs"
}

inputs = {
  environments = "dev"
  key_name     = "dev-key"  # Used as prefix for IAM resources
  
  # S3 bucket for SSM session logs
  ssm_s3_bucket_name = dependency.s3_ssm_logs.outputs.bucket_id
  
  ec2_parameters = {
    instance_count = 3
    ami_id         = "ami-0360c520857e3138f"
    instance_type  = "t2.nano"
    subnet_ids     = dependency.vpc.outputs.public_subnet_ids
    
    tags = {
      Role         = "frontend"
      Environments = "dev"
    }
  }
  
  security_group_ids = [
    dependency.vpc.outputs.sg_ids["ssh"],
    dependency.vpc.outputs.sg_ids["web"]
  ]
}