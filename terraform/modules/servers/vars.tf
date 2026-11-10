variable "environments" {
  type = string
  validation {
    condition = contains(["dev", "prod", "stage"], var.environments)
    error_message = "The environment entered does not exist."
  }
  default     = "dev"
  description = "This describes the environment namespace"
}

variable "key_name" {
  description = "Name prefix for IAM resources (previously used for SSH key name)"
  type        = string
}

variable "security_group_ids" {
  description = "List of SGs to attach to EC2 instances"
  type        = list(string)
  default     = []
}

variable "ec2_parameters" {
  description = "Map of EC2 instance configurations, keyed by role/purpose"
  type = map(object({
    instance_count = number
    ami_id         = string
    instance_type  = string
    subnet_ids     = list(string)
    tags           = optional(map(string), {})
  }))
  
  # Example:
  # {
  #   frontend = {
  #     instance_count = 2
  #     ami_id         = "ami-xxx"
  #     instance_type  = "t2.nano"
  #     subnet_ids     = ["subnet-xxx"]
  #     tags           = { Role = "frontend" }
  #   }
  #   monitor = {
  #     instance_count = 1
  #     ami_id         = "ami-xxx"
  #     instance_type  = "t2.small"
  #     subnet_ids     = ["subnet-xxx"]
  #     tags           = { Role = "monitor" }
  #   }
  # }
}

variable "ssm_s3_bucket_name" {
  description = "S3 bucket name for SSM session logs (optional)"
  type        = string
  default     = null
}
