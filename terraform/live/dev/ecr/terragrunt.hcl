include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/ecr"
}

inputs = {
  repositories = {
    portfolio-landing-page = {
      image_tag_mutability = "MUTABLE"
      scan_on_push         = true
      encryption_type      = "AES256"
      lifecycle_policy = {
        untagged_days      = 7
        tagged_count_limit = 20
      }
      tags = {
        Application = "Portfolio"
        Environment = "dev"
      }
    }

    # Example: Add more repositories as you build microservices
    # backend-api = {
    #   image_tag_mutability = "IMMUTABLE"
    #   scan_on_push         = true
    #   lifecycle_policy = {
    #     untagged_days      = 3
    #     tagged_count_limit = 50
    #   }
    # }
  }

  common_tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
    Project     = "e-2-e-infrastructure"
  }
}
