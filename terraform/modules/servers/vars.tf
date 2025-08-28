variable "environments" {
  type = string
  validation {
    condition = contains(["dev", "prod", "stage"], var.environments)
    error_message = "The environment entered does not exist."
  }
  default     = "dev"
  description = "This describes the environment namespace"
}


variable "ec2_parameters" {
  type = object({
    instance_count = number
    instance_type  = string
    subnet_ids     = list(string)
    tags           = optional(map(string), {})
  })
}