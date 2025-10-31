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
  region = var.aws_region
}

# VPC Configuration - Use existing or create new
locals {
  vpc_id = var.use_existing_vpc ? var.existing_vpc_id : module.vpc[0].vpc_id
  public_subnets = var.use_existing_vpc ? var.existing_public_subnets : module.vpc[0].public_subnets
}

# Conditionally create VPC only if not using existing
module "vpc" {
  count = var.use_existing_vpc ? 0 : 1

  source = "./modules/vpc"

  name_prefix    = local.name_prefix
  vpc_cidr       = var.vpc_cidr
  azs            = var.availability_zones
  public_subnets = var.public_subnets

  tags = local.common_tags
}

# Get existing VPC data if using existing VPC
data "aws_vpc" "existing" {
  count = var.use_existing_vpc ? 1 : 0
  id    = var.existing_vpc_id
}

data "aws_subnets" "existing_public" {
  count = var.use_existing_vpc ? 1 : 0
  
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }
  
  filter {
    name   = "tag:Name"
    values = ["*public*"]
  }
}
