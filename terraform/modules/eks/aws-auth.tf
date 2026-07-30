data "aws_eks_cluster" "this" {
  name = aws_eks_cluster.example.name
}

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.example.name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

locals {
  aws_auth_map_roles = [
    {
      rolearn  = aws_iam_role.node.arn
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
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(local.aws_auth_map_roles)
    mapUsers = yamlencode(local.aws_auth_map_users)
  }
}
