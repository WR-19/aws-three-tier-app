output "application_url" {
  description = "URL where the application will be accessible"
  value       = "http://YOUR-ALB-URL (to be configured after deployment)"
}

output "next_steps" {
  description = "Instructions for next steps after Terraform applies"
  value       = <<EOT

Next steps to complete the deployment:

1. Build and push Docker image to ECR:
   cd backend
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${module.ecs.ecr_repository_url}
   docker build -t ${module.ecs.ecr_repository_url}:latest .
   docker push ${module.ecs.ecr_repository_url}:latest

2. Initialize the database:
   export DB_HOST=${module.rds.database_host}
   export DB_NAME=${var.database_name}
   export DB_USER=${var.database_user}
   export DB_PASSWORD=${module.rds.database_password}
   cd backend && python init_db.py

3. Update frontend with actual API URL
   - Edit frontend/index.html
   - Replace 'YOUR-API-URL-HERE' with the ALB URL

4. Deploy frontend to S3 (manual step for now)
EOT
}
