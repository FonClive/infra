variable "repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    image_tag_mutability  = optional(string, "MUTABLE")
    scan_on_push          = optional(bool, true)
    encryption_type       = optional(string, "AES256")
    kms_key_arn          = optional(string, null)
    lifecycle_policy     = optional(object({
      untagged_days      = optional(number, 7)
      tagged_count_limit = optional(number, 10)
    }), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "github_actions_iam_role_arn" {
  description = "IAM role ARN used by GitHub Actions for pushing images"
  type        = string
  default     = ""
}

variable "enable_cross_account_access" {
  description = "Enable cross-account pull access"
  type        = bool
  default     = false
}

variable "cross_account_principal_arns" {
  description = "List of AWS account ARNs to grant pull access"
  type        = list(string)
  default     = []
}

variable "common_tags" {
  description = "Common tags to apply to all repositories"
  type        = map(string)
  default     = {}
}
