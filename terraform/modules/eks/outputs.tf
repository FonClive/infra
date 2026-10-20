output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.example.endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = aws_eks_cluster.example.certificate_authority[0].data
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.example.name
}

output "cluster_oidc_issuer_url" {
  description = "OIDC identity provider URL"
  value       = aws_eks_cluster.example.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  description = "ARN of OIDC provider for IRSA"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "node_role_arn" {
  description = "ARN of node IAM role for aws-auth"
  value       = aws_iam_role.node.arn
}

output "bootstrap_user_arns" {
  description = "IAM user ARNs to grant cluster access"
  value       = var.bootstrap_user_arns
}
