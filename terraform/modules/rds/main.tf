# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${var.name_prefix}-rds"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow from entire VPC for now
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

# Generate random password for database
resource "random_password" "database" {
  length  = 16
  special = false
}

# RDS PostgreSQL Instance
resource "aws_db_instance" "main" {
  identifier              = "${var.name_prefix}-db"
  engine                  = "postgres"
  engine_version          = "14.9"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = var.database_name
  username                = var.database_user
  password                = random_password.database.result
  vpc_security_group_ids  = [aws_security_group.rds.id]
  skip_final_snapshot     = true
  backup_retention_period = 1
  publicly_accessible     = false

  tags = var.tags
}

# Outputs
output "database_host" {
  description = "RDS instance hostname"
  value       = aws_db_instance.main.address
}

output "database_password" {
  description = "RDS instance password"
  value       = random_password.database.result
  sensitive   = true
}
