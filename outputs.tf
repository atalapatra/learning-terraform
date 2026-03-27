output "bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.my_bucket.bucket_name
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = module.my_bucket.bucket_arn
}

output "logs_bucket_name" {
  description = "The name of the logs S3 bucket"
  value       = module.logs_bucket.bucket_name
}

output "logs_bucket_arn" {
  description = "The ARN of the logs S3 bucket"
  value       = module.logs_bucket.bucket_arn
}
