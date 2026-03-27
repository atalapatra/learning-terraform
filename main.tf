terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "learning-terraform-amit-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
  }
}

provider "aws" {
  region = var.aws_region
}

# Look up the IAM role created by bootstrap — pipeline manages its own permissions from here
data "aws_iam_role" "github_actions" {
  name = "github-actions-learning-terraform"
}

resource "aws_iam_role_policy" "github_actions" {
  name = "github-actions-learning-terraform-policy"
  role = data.aws_iam_role.github_actions.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3FullAccess"
        Effect = "Allow"
        Action = ["s3:*"]
        Resource = [
          "arn:aws:s3:::learning-terraform-amit-*",
          "arn:aws:s3:::learning-terraform-amit-*/*",
        ]
      },
      {
        Sid    = "IAMSelfPolicy"
        Effect = "Allow"
        Action = [
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRole"
        ]
        Resource = "arn:aws:iam::*:role/github-actions-learning-terraform"
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

module "my_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.bucket_name
  versioning_enabled = true
}

module "logs_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.logs_bucket_name
  versioning_enabled = false
}

module "archive_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.archive_bucket_name
  versioning_enabled = false
}
