terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# GitHub's OIDC provider — tells AWS to trust tokens issued by GitHub Actions
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC thumbprint (stable, does not change often)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# The IAM role that GitHub Actions will assume
resource "aws_iam_role" "github_actions" {
  name = "github-actions-learning-terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            # Only tokens from this specific repo can assume this role
            "token.actions.githubusercontent.com:sub" = "repo:atalapatra/learning-terraform:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Permissions the role needs to manage S3 resources + read/write remote state
resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-learning-terraform-policy"
  role = aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::learning-terraform-amit-2026",
          "arn:aws:s3:::learning-terraform-amit-2026/*",
          "arn:aws:s3:::learning-terraform-amit-state",
          "arn:aws:s3:::learning-terraform-amit-state/*"
        ]
      },
      {
        Sid    = "DynamoDBStateLock"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:*:table/terraform-state-lock"
      }
    ]
  })
}

output "role_arn" {
  description = "ARN of the IAM role — add this as the AWS_ROLE_ARN secret in GitHub"
  value       = aws_iam_role.github_actions.arn
}
