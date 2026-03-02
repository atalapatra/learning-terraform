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

module "my_bucket" {
  source             = "./modules/s3_bucket"
  bucket_name        = var.bucket_name
  versioning_enabled = true
}
