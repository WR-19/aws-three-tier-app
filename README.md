# AWS Three-Tier Web Application

A cloud-native application demonstrating modern DevOps practices and AWS services.

## Architecture
- **Frontend**: HTML/JS on S3 + CloudFront
- **Backend**: Python Flask API on ECS Fargate 
- **Database**: PostgreSQL on RDS
- **Infrastructure**: Terraform (IaC)
- **CI/CD**: GitHub Actions

## Features
- RESTful API with Flask
- Docker containerization
- Infrastructure as Code with Terraform
- Automated testing with GitHub Actions
- Database migrations
- Health monitoring

## Technologies
- AWS (ECS, RDS, S3, VPC, IAM)
- Terraform
- Docker
- Python/Flask
- PostgreSQL
- GitHub Actions

## Project Structure
aws-three-tier-project/
├── terraform/ # Infrastructure code
├── backend/ # Python API
├── frontend/ # Web interface
└── .github/ # CI/CD workflows

## Deployment
1. `terraform init` - Initialize Terraform
2. `terraform plan` - Review changes
3. `terraform apply` - Deploy infrastructure
4. `python init_db.py` - Setup database

## Skills Demonstrated
- Cloud Architecture
- Infrastructure as Code
- Containerization
- CI/CD Pipelines
- Database Management
- REST API Development
