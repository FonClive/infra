# IAM policy for GitHub Actions to push to ECR
data "aws_iam_policy_document" "github_actions_push" {
  count = var.github_actions_iam_role_arn != "" ? 1 : 0

  statement {
    sid    = "ECRPushAccess"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ECRRepositoryAccess"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      for repo in aws_ecr_repository.this : repo.arn
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  count = var.github_actions_iam_role_arn != "" ? 1 : 0

  name        = "GitHubActionsECRAccess"
  description = "Allow GitHub Actions to push images to ECR"
  policy      = data.aws_iam_policy_document.github_actions_push[0].json

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  count = var.github_actions_iam_role_arn != "" ? 1 : 0

  role       = split("/", var.github_actions_iam_role_arn)[1]
  policy_arn = aws_iam_policy.github_actions_ecr[0].arn
}
