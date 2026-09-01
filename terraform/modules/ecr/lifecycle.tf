resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.repositories

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images after ${each.value.lifecycle_policy.untagged_days} days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = each.value.lifecycle_policy.untagged_days
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep only ${each.value.lifecycle_policy.tagged_count_limit} tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v", "main", "develop"]
          countType     = "imageCountMoreThan"
          countNumber   = each.value.lifecycle_policy.tagged_count_limit
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
