include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/eks/"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  cluster_name = "pamfes-dev-cluster"
  cluster_version = "1.34"
  node_role_name = "pamfes-dev-eks-node-role"
  cluster_role = "pamfes-dev-eks-cluster-role"
  subnet_ids = dependency.vpc.outputs.private_subnet_ids
}
