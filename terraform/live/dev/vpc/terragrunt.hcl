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
  # NAT Gateway
  # -----------------------
  nat_gateway_parameters = {
    main-nat = {
      vpc_name    = "main-vpc"
      subnet_name = "public-subnet-1"
      tags = {
        Name = "main-nat"
      }
    }
  }

  # -----------------------
  # Route Tables + Routes
  # -----------------------
  rt_parameters = {
    public-rt = {
      subnet_names = ["public-subnet-1", "public-subnet-2"]
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          use_igw                = true
          gateway_id             = "main-igw"
        }
      ]
      tags = {
        tier = "public"
      }
    }

    private-rt = {
      subnet_names = ["private-subnet-1", "private-subnet-2"]
      routes = [
        {
          destination_cidr_block = "0.0.0.0/0"
          use_nat_gw             = true
          gateway_id             = "main-nat"
        }
      ]
      tags = {
        tier = "private"
      }
    }
  }

  # Security Groups

  
sg_parameters = {
    ssh = {
      vpc_name    = "main-vpc"
      description = "Allow SSH"
      ingress = [
        {
          description = "SSH"
          from_port   = 22
          to_port     = 22
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"] # for lab purpose only
        }
      ]
      egress = [
        {
          description = "All traffic"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }

    web = {
      vpc_name    = "main-vpc"
      description = "Allow HTTP/HTTPS"
      ingress = [
        {
          description = "HTTP"
          from_port   = 80
          to_port     = 80
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        },
        {
          description = "HTTPS"
          from_port   = 443
          to_port     = 443
          protocol    = "tcp"
          cidr_blocks = ["0.0.0.0/0"]
        }
      ]
    }
  }
}

