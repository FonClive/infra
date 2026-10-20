# modules/k8s-initial-bootstrap/main.tf

# access to the eks cluster after its provisioned
locals {
  aws_auth_map_roles = [
    {
      rolearn  = var.node_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  aws_auth_map_users = [
    for userarn in var.bootstrap_user_arns : {
      userarn  = userarn
      username = split("/", userarn)[length(split("/", userarn)) - 1]
      groups   = ["system:masters"]
    }
  ]
}

resource "kubernetes_config_map_v1" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.aws_auth_map_roles)
    mapUsers = yamlencode(local.aws_auth_map_users)
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations, metadata[0].labels]
  }
}

# Create namespaces
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name       = "argocd"
      managed-by = "terraform"
    }
  }
}

# Additional namespaces for future platform tools
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

# # Deploy ArgoCD
# resource "helm_release" "argocd" {
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   version          = "7.3.0"
#   namespace        = kubernetes_namespace_v1.argocd.metadata[0].name
#   create_namespace = false

#   set = [
#     {
#     name  = "server.service.type"
#     value = "LoadBalancer"
#   }
#   ]
# }
