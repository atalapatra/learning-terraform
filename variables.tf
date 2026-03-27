variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "logs_bucket_name" {
  description = "The name of the logs S3 bucket"
  type        = string
}

variable "archive_bucket_name" {
  description = "The name of the archive S3 bucket"
  type        = string
}
