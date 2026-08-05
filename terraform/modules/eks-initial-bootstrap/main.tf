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

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kubesystem"
  }

  data = {
    mapRoles = yamlencode(local.aws_auth_map_roles)
    mapUsers = yamlencode(local.aws_auth_map_users)
  }
}

# Create namespaces
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name = "argocd"
      managed-by = "terraform"
    }
  }
}

# Additional namespaces for future platform tools
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}


# 2. Deploy your Baseline Controller (Example: ArgoCD or a basic Helm Application)
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "7.3.0"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false  # We already created it

  set {
    name  = "server.service.type"
    value = "LoadBalancer"  # Changed from ClusterIP for easier access
  }

  # Optional: Configure initial admin password
  # set {
  #   name  = "configs.secret.argocdServerAdminPassword"
  #   value = bcrypt(var.argocd_admin_password)
  # }
}

