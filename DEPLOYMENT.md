# Deployment Guide

## VPC Limit Solution

This project supports both creating new VPCs and using existing VPCs to work around AWS VPC limits.

### Option A: Use Existing VPC (Recommended for Free Tier)
```bash
cd terraform

# Get your VPC and subnet IDs
aws ec2 describe-vpcs --query 'Vpcs[*].{VpcId:VpcId,IsDefault:IsDefault,CidrBlock:CidrBlock}'
aws ec2 describe-subnets --query 'Subnets[*].{SubnetId:SubnetId,VpcId:VpcId,CidrBlock:CidrBlock}'

# Deploy with existing VPC
terraform apply -var="use_existing_vpc=true" -var="existing_vpc_id=vpc-xxxxxx" -var="existing_public_subnets=['subnet-xxxxxx','subnet-yyyyyy']"
