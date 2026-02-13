variable "efs_params" {
  description = "Describes all the parameters needed for efs"
  type = map(object({
    creation_token = string
    performance_mode = string
    throughput_mode = string
    tags = map(string)
  }))  
}

variable "subnet_id" {
  description = " Describes the parameters required for efs mount targets"
  type = list(string)
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