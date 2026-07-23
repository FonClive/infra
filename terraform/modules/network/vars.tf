variable "environments" {
  type = string
  validation {
    condition = contains(["dev", "prod", "stage"], var.environments)
    error_message = "The environment entered does not exist."
  }
  default     = "dev"
  description = "This describes the environment namespace"
}

variable "vpc_parameters" {
    description = "VPC parameters"
    type = map(object({
        cidr_block = string 
        enable_dns_support = optional(bool, true)
        enable_dns_hostnames = optional(bool, true)
        tags = optional(map(string), {})
    }))
    default = {}
}

variable "subnet_parameters" {
  description = "subnets parameters"
  type = map(object({
    name = string
    cidr_block = string 
    vpc_name = string 
    az = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "igw_parameters" {
  description = "Internet Gateway Parameters"
  type = map(object({
    vpc_name =string 
    tags = optional(map(string), {})
  }))
  default = {}

}

variable "rt_parameters" {
  description = "Route table parameters"
  type = map(object({
    subnet_names = list(string) 
    tags = optional(map(string), {})
    routes = optional(list(object({
      destination_cidr_block = string
      use_igw = optional(bool, false)
      use_nat_gw = optional(bool, false)
      gateway_id =string
    })), [])
  }))
  default = {}
}

variable "nat_gateway_parameters" {
  description = "NAT Gateway parameters"
  type = map(object({
    vpc_name = string
    subnet_name = string
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "sg_parameters" {
  description = "Map of security groups to create"
  type = map(object({
    vpc_name    = string
    description = optional(string, "Managed by Terraform")
    ingress = optional(list(object({
      description = optional(string, "Ingress rule")
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), [])

    egress = optional(list(object({
      description = optional(string, "Egress rule")
      from_port   = number
      to_port     = number
      protocol    = string
      cidr_blocks = list(string)
    })), [])
  }))
  default = {}
}

