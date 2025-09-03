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
  description = "Name of the SSH key pair to use for EC2 instances"
  type        = string
}

variable "security_group_ids" {
  description = "List of SGs to attach to EC2 instances"
  type        = list(string)
  default     = []
}

variable "public_key_path" {
  description = "Path to an existing SSH public key file"
  type        = string
  default     = ""
}

variable "ec2_parameters" {
  type = object({
    instance_count = number
    instance_type  = string
    subnet_ids     = list(string)
    tags           = optional(map(string), {})
  })
}