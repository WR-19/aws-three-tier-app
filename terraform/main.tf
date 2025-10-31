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

  name_prefix     = local.name_prefix
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  database_name   = var.database_name
  database_user   = var.database_user

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
  value = module.vpc.vpc_id
}

output "database_host" {
  value = module.rds.database_host
}

output "ecs_cluster_name" {
  value = module.ecs.ecs_cluster_name
}

output "ecr_repository_url" {
  value = module.ecs.ecr_repository_url
}
