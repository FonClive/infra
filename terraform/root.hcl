locals {
  module_path = path_relative_to_include()
  # Modules that require Kubernetes/Helm providers
  is_kubernetes_module = (
    can(regex(".*/eks/bootstrap.*", local.module_path))
    # Add more patterns here as needed, e.g.:
    # || can(regex(".*/argocd.*", local.module_path))
  )
  
  kubernetes_provider_config = <<-EOF
provider "kubernetes" {
  host                   = var.kubernetes_cluster_endpoint
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.kubernetes_cluster_name]
    command     = "aws"
  }
}

# Helm provider will use kubeconfig from environment or the kubernetes provider context
provider "helm" {
}

variable "kubernetes_cluster_endpoint" { type = string }
variable "kubernetes_cluster_ca"       { type = string }
variable "kubernetes_cluster_name"     { type = string }
EOF
}



remote_state {
  backend = "s3"
  generate = {
    path = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    bucket = "pamfes-state-bucket"
    key = "${path_relative_to_include()}/tofu.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "pamfes-lock-table"
    s3_bucket_tags = {
      name = "pam-fes-infra-remote-state-bucket"
    }

  }
}

# Dynamically generated provider that relies on Terragrunt variables
generate "provider" {
  path      = "provider_kubernetes.tf"
  if_exists = "overwrite_terragrunt"
  contents  = local.is_kubernetes_module ? local.kubernetes_provider_config : ""
}
