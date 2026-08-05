variable "cluster_name" {
  type = string
  default = ""
}

variable "cluster_version" {
  type = string
  default = ""
  
}

variable "subnet_ids" {
  type = list(string)
  default = []
}

variable "node_role_name" {
  type = string
  default = ""
}

variable "cluster_role_name" {
  type = string
  default = ""
}

variable "bootstrap_user_arns" {
  description = "List of IAM user ARNs to add to aws-auth as cluster admin bootstrappers"
  type        = list(string)
  default     = []
}
