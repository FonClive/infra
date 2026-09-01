# modules/k8s-initial-bootstrap/variables.tf
variable "node_role_arn" {
  description = "ARN of the EKS node IAM role for aws-auth mapping"
  type        = string
}

variable "bootstrap_user_arns" {
  description = "List of IAM user ARNs to grant cluster admin access"
  type        = list(string)
  default     = []
}
