include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/eks-initial-bootstrap"
}

# Pull live configurations from the parent EKS folder
dependency "eks" {
  config_path = ".."

  # Mock data keeps 'terragrunt run-all plan' safe while the cluster is being built
  mock_outputs = {
    cluster_endpoint                   = "https://amazonaws.com"
    cluster_certificate_authority_data = "Ym9ndXMtY2EtY2VydGlmaWNhdGUtZGF0YQ==" 
    cluster_name                       = "mock-cluster"
    node_role_arn                      = "arn:aws:iam::123456789012:role/mock-node-role"
    bootstrap_user_arns                = []
  }
  
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}


inputs = {
  # Pass cluster connection info to K8s provider (via root.hcl variables)
  kubernetes_cluster_endpoint = dependency.eks.outputs.cluster_endpoint
  kubernetes_cluster_ca       = dependency.eks.outputs.cluster_certificate_authority_data
  kubernetes_cluster_name     = dependency.eks.outputs.cluster_name

  # Pass to bootstrap module for aws-auth ConfigMap
  node_role_arn               = dependency.eks.outputs.node_role_arn
  bootstrap_user_arns         = dependency.eks.outputs.bootstrap_user_arns
}
