variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The globally unique name of the S3 bucket."
  type        = string
}
