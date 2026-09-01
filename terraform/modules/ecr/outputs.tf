output "repository_urls" {
  description = "Map of repository names to their URLs"
  value = {
    for k, v in aws_ecr_repository.this : k => v.repository_url
  }
}

output "repository_arns" {
  description = "Map of repository names to their ARNs"
  value = {
    for k, v in aws_ecr_repository.this : k => v.arn
  }
}

output "registry_id" {
  description = "The registry ID where the repositories were created"
  value       = try(values(aws_ecr_repository.this)[0].registry_id, "")
}

output "repository_names" {
  description = "List of repository names"
  value       = keys(aws_ecr_repository.this)
}
