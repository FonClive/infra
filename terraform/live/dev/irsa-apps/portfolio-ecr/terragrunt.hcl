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
  app_name             = "portfolio"
  namespace            = "portfolio"
  service_account_name = "portfolio-sa"

  # EKS OIDC info
  cluster_name       = dependency.eks.outputs.cluster_name
  oidc_provider_arn  = dependency.eks.outputs.oidc_provider_arn
  oidc_provider_url  = dependency.eks.outputs.cluster_oidc_issuer_url

  # ECR access policy
  inline_policies = {
    ecr_pull = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowECRPull"
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage"
          ]
          Resource = "*"
        }
      ]
    })
  }

  # Optional: Use managed policies instead
  # managed_policy_arns = [
  #   "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  # ]

  tags = {
    App         = "portfolio"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
