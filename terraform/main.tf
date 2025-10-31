terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Local values
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# Modules
module "vpc" {
  source = "./modules/vpc"

  name_prefix     = local.name_prefix
  vpc_cidr        = var.vpc_cidr
  azs             = var.availability_zones
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  tags = local.common_tags
}

module "rds" {
  source = "./modules/rds"

  name_prefix              = local.name_prefix
  vpc_id                   = module.vpc.vpc_id
  private_subnets          = module.vpc.private_subnets
  allowed_security_groups  = [module.ecs.ecs_service_security_group_id]
  database_name            = var.database_name
  database_user            = var.database_user

  tags = local.common_tags
}

module "ecs" {
  source = "./modules/ecs"

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  private_subnets   = module.vpc.private_subnets
  database_host     = module.rds.database_host
  database_name     = var.database_name
  database_user     = var.database_user
  database_password = module.rds.database_password

  tags = local.common_tags
}

# Output all important values
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "database_host" {
  description = "RDS instance hostname"
  value       = module.rds.database_host
  sensitive   = true
}

output "database_password" {
  description = "RDS instance password"
  value       = module.rds.database_password
  sensitive   = true
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.ecs_cluster_name
}

output "ecr_repository_url" {
  description = "ECR repository URL for Docker images"
  value       = module.ecs.ecr_repository_url
}

output "public_subnets" {
  description = "List of public subnet IDs"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = module.vpc.private_subnets
}
