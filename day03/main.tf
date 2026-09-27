terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. S3 Bucket
resource "aws_s3_bucket" "prod_bucket" {
  bucket        = var.bucket_name
  force_destroy = false # Prevent accidental deletion of production data

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# # 2. Server-Side Encryption (AES-256)
# resource "aws_s3_bucket_server_side_encryption_by_default" "encryption" {
#   bucket = aws_s3_bucket.prod_bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }

# 3. Enable Versioning for data protection
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.prod_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 4. Block Public Access (Crucial for Production)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.prod_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
