# SSM Session Logs S3 Bucket

## Purpose
This S3 bucket stores AWS Systems Manager (SSM) Session Manager logs for EC2 instances. SSM requires an S3 bucket to function properly with Ansible.

## Deployment Order

**IMPORTANT**: This bucket must be created BEFORE deploying EC2 servers.

### Step 1: Deploy S3 Bucket
```bash
cd infra/terraform/live/dev/s3-ssm-logs
terragrunt apply
```

### Step 2: Get the Bucket Name
```bash
terragrunt output bucket_id
# Output: dev-ssm-session-logs-123456789012
```

### Step 3: Update Servers Configuration
After the bucket is created, you need to:

1. Update `infra/terraform/live/dev/servers/terragrunt.hcl` to include the bucket name:
```hcl
inputs = {
  # ... existing config ...
  ssm_s3_bucket_name = dependency.s3_ssm_logs.outputs.bucket_id
}
```

2. Add dependency in servers terragrunt.hcl:
```hcl
dependency "s3_ssm_logs" {
  config_path = "../s3-ssm-logs"
}
```

### Step 4: Update Ansible Configuration
The Ansible configuration in `infra/ansible/group_vars/all.yaml` already references the bucket:
```yaml
ansible_aws_ssm_bucket_name: "dev-ssm-session-logs-{{ lookup('env', 'AWS_ACCOUNT_ID') }}"
```

Make sure the `AWS_ACCOUNT_ID` environment variable is set in your CI/CD pipeline.

### Step 5: Deploy Servers
```bash
cd infra/terraform/live/dev/servers
terragrunt apply
```

## Features

- **Encryption**: AES256 encryption at rest
- **Lifecycle**: 
  - After 30 days: Move to Standard-IA
  - After 60 days: Move to Glacier
  - After 90 days: Delete
- **Public Access**: Completely blocked
- **Versioning**: Disabled (not needed for logs)

## Troubleshooting

### SSM Connection Fails with NoneType Error
This error occurs when SSM cannot write logs to S3. Verify:
1. S3 bucket exists
2. Instance IAM role has S3 write permissions
3. Ansible configuration includes `ansible_aws_ssm_bucket_name`

### Permission Denied
Check that:
1. EC2 instance role has `s3:PutObject` permission for the bucket
2. S3 bucket policy allows the EC2 instance role ARN

## Cost Estimation
- Storage: ~$0.023/GB/month (Standard tier)
- Typical usage: ~100MB/month per instance = $0.002/month per instance
- After 30 days transitions to IA: $0.0125/GB/month
