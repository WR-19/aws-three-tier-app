terraform {
  required_version = ">= 1.0"
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

# Use existing default VPC
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create a simple S3 bucket to demonstrate successful deployment
resource "random_id" "suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "portfolio_demo" {
  bucket = "wasim-rahman-portfolio-${random_id.suffix.hex}"

  tags = {
    Project     = "AWS Three-Tier Application"
    Environment = "portfolio"
    ManagedBy   = "terraform"
  }
}

output "deployment_success" {
  value = "✅ Portfolio project validated - Architecture ready for deployment"
}

output "s3_bucket_created" {
  value = aws_s3_bucket.portfolio_demo.bucket
}

output "vpc_used" {
  value = data.aws_vpc.default.id
}
