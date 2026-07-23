resource "aws_eks_addon" "vpc_cni" {
  cluster_name             = aws_eks_cluster.example.name
  addon_name               = "vpc-cni"
  service_account_role_arn = aws_iam_role.vpc_cni.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.example]
}

resource "aws_eks_addon" "core_dns" {
  cluster_name             = aws_eks_cluster.example.name
  addon_name               = "coredns"
  service_account_role_arn = aws_iam_role.coredns.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.example]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name             = aws_eks_cluster.example.name
  addon_name               = "kube-proxy"
  service_account_role_arn = aws_iam_role.kube_proxy.arn

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_eks_cluster.example]
}
