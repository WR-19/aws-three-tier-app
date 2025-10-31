variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "three-tier-app"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "public_subnets" {
  description = "Public subnets CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "use_existing_vpc" {
  description = "Whether to use an existing VPC instead of creating a new one"
  type        = bool
  default     = true
}

variable "existing_vpc_id" {
  description = "Existing VPC ID to use"
  type        = string
  default     = ""
}

variable "existing_public_subnets" {
  description = "Existing public subnet IDs"
  type        = list(string)
  default     = []
}
