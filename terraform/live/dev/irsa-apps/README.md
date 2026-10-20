# Portfolio Application Infrastructure

This directory contains all infrastructure configurations for the portfolio landing page application.

## Components

### IRSA (IAM Role for Service Account)
- **Location:** `irsa/terragrunt.hcl`
- **Purpose:** Grants portfolio pods access to ECR for image pulls
- **Role Name:** `pamfes-dev-cluster-portfolio-irsa`
- **Service Account:** `portfolio:portfolio-sa`
- **Permissions:** ECR read-only

## Dependencies

- **EKS Cluster:** Required for OIDC provider
- **ECR Repository:** `portfolio-landing-page`

## Deployment

```bash
# Deploy IRSA role
cd infra/terraform/live/dev/apps/portfolio/irsa
terragrunt apply

# Get role ARN for K8s ServiceAccount
terragrunt output role_arn
