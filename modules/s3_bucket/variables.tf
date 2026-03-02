variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Whether to enable versioning on the bucket"
  type        = bool
  default     = false
}
