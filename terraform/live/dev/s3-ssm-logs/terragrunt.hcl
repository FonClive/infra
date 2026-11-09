##############################################
# S3 Bucket for SSM Session Logs
##############################################
# This bucket stores SSM session manager logs
# for EC2 instances in the dev environment
##############################################

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/s3"
}

##############################################
# Inputs
##############################################

inputs = {
  bucket_name       = "dev-ssm-session-logs-${get_aws_account_id()}"
  environment       = "dev"
  force_destroy     = true  # Set to false in production
  enable_versioning = false # SSM logs don't need versioning
  
  # Enable SSM session logging policy
  enable_ssm_logs = true
  
  # Will be populated after servers module is applied
  ssm_instance_role_arns = [
    # These will be added via dependency or manually after servers are created
    # dependency.servers.outputs.instance_role_arn
  ]
  
  # Encryption
  sse_algorithm      = "AES256"
  bucket_key_enabled = true
  
  # Public access - completely blocked
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  
  # Lifecycle rules - delete old logs after 90 days
  lifecycle_rules = [
    {
      id      = "delete-old-ssm-logs"
      enabled = true
      prefix  = null
      expiration_days = 90
      noncurrent_version_expiration_days = null
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
    }
  ]
  
  tags = {
    Purpose    = "SSM Session Logs"
    Compliance = "Required for audit trail"
  }
}
