##############################################
# S3 Bucket Variables
##############################################

variable "bucket_name" {
  description = "Name of the S3 bucket (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Additional tags for the S3 bucket"
  type        = map(string)
  default     = {}
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
  default     = false
}

##############################################
# Versioning
##############################################

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = false
}

##############################################
# Encryption
##############################################

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (AES256 or aws:kms)"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "aws:kms"], var.sse_algorithm)
    error_message = "SSE algorithm must be either AES256 or aws:kms"
  }
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption (required if sse_algorithm is aws:kms)"
  type        = string
  default     = null
}

variable "bucket_key_enabled" {
  description = "Enable S3 Bucket Key for SSE-KMS"
  type        = bool
  default     = true
}

##############################################
# Public Access Block
##############################################

variable "block_public_acls" {
  description = "Block public ACLs"
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Block public bucket policies"
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Ignore public ACLs"
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Restrict public bucket policies"
  type        = bool
  default     = true
}

##############################################
# Lifecycle Rules
##############################################

variable "lifecycle_rules" {
  description = "List of lifecycle rules for the bucket"
  type = list(object({
    id                                    = string
    enabled                               = bool
    prefix                                = optional(string)
    expiration_days                       = optional(number)
    noncurrent_version_expiration_days    = optional(number)
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })))
  }))
  default = []
}

##############################################
# Bucket Policy
##############################################

variable "bucket_policy" {
  description = "Custom bucket policy JSON"
  type        = string
  default     = null
}

##############################################
# SSM Session Logging
##############################################

variable "enable_ssm_logs" {
  description = "Enable SSM session logging policy"
  type        = bool
  default     = false
}

variable "ssm_instance_role_arns" {
  description = "List of EC2 instance role ARNs that need to write SSM logs"
  type        = list(string)
  default     = []
}

##############################################
# Logging
##############################################

variable "logging_target_bucket" {
  description = "Target bucket for access logs"
  type        = string
  default     = null
}

variable "logging_target_prefix" {
  description = "Prefix for access logs in target bucket"
  type        = string
  default     = "logs/"
}
