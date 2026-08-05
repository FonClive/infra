# modules/k8s-initial-bootstrap/variables.tf

variable "kubernetes_cluster_endpoint" {
  description = "The endpoint of the created AWS EKS cluster"
  type        = string
}

variable "kubernetes_cluster_ca" {
  description = "The base64 encoded certificate authority data"
  type        = string
}

variable "kubernetes_cluster_name" {
  description = "The name of the target EKS cluster"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the EKS node IAM role for aws-auth mapping"
  type        = string
}

variable "bootstrap_user_arns" {
  description = "List of IAM user ARNs to grant cluster admin access"
  type        = list(string)
  default     = []
}
