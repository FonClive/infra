include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/app-irsa"
}

# Dependency on EKS for OIDC provider info
dependency "eks" {
  config_path = "../../eks"
}

inputs = {
  # App identification
  app_name             = "aws-load-balancer-controller"
  namespace            = "kube-system"
  service_account_name = "aws-load-balancer-controller"

  # EKS OIDC info
  cluster_name      = dependency.eks.outputs.cluster_name
  oidc_provider_arn = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url = dependency.eks.outputs.cluster_oidc_issuer_url

  # ALB controller IAM policy
  inline_policies = {
    alb_controller = file("${get_terragrunt_dir()}/alb-controller-policy.json")
  }

  # Optional: Use managed policies instead
  # managed_policy_arns = []

  tags = {
    App         = "aws-load-balancer-controller"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
