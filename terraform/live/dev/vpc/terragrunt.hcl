include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/network/"
}

inputs = {
  environments = "dev"

  # -----------------------
  # VPC
  # -----------------------
  vpc_parameters = {
    main-vpc = {
      cidr_block           = "10.0.0.0/16"   # good range for multiple tiers
      enable_dns_support   = true
      enable_dns_hostnames = true
      tags = {
        Name = "pamfes-infra-vpc"
      }
    }
  }

  # -----------------------
  # Subnets
  # -----------------------
  subnet_parameters = {
    public-subnet-1 = {
      name       = "public-subnet-1"
      cidr_block = "10.0.1.0/24"
      vpc_name   = "main-vpc"
      az         = "us-east-1a"
      tags = {
        tier = "frontend"
        Name = "pamfes-pubsub-1"
      }
    }

    public-subnet-2 = {
      name       = "public-subnet-2"
      cidr_block = "10.0.2.0/24"
      vpc_name   = "main-vpc"
      az         = "us-east-1b"
      tags = {
        tier = "frontend"
        Name = "pamfes-pubsub-2"
      }
    }

    private-subnet-1 = {
      name       = "private-subnet-1"
      cidr_block = "10.0.101.0/24"
      vpc_name   = "main-vpc"
      az         = "us-east-1a"
      tags = {
        tier = "backend"
        Name = "pamfes-privsub-1"
      }
    }

    private-subnet-2 = {
      name       = "private-subnet-2"
      cidr_block = "10.0.102.0/24"
      vpc_name   = "main-vpc"
      az         = "us-east-1b"
      tags = {
        tier = "backend"
        Name = "pamfes-privsub-2"
      }
    }
  }

  # -----------------------
  # Internet Gateway
  # -----------------------
  igw_parameters = {
    main-igw = {
      vpc_name = "main-vpc"
      tags = {
        Name = "main-igw"
      }
    }
  }

  # -----------------------
  # Route Tables + Routes
  # -----------------------
  rt_parameters = {
    public-rt = {
      subnet_name = "public-subnet-1" # associate with at least one public subnet
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0" # default route to Internet
          use_igw                = true
          gateway_id             = "main-igw"
        }
      ]
      tags = {
        tier = "public"
      }
    }
  }
}