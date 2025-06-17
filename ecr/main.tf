# AWS ECR Repository - app_ecr
resource "aws_ecr_repository" "webapp_ecr" {
  name                 = "${var.environment}-${var.ecr_repository_name}"
  image_tag_mutability = var.ecr_image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.ecr_enable_image_scanning
  }

  tags = {
    Name        = "${var.environment}-${var.ecr_repository_name}"
    Environment = var.environment
  }
}

# Lifecycle Policy for ECR - app_ecr
resource "aws_ecr_lifecycle_policy" "webapp_ecr_lifecycle" {
  repository = aws_ecr_repository.webapp_ecr.name
  policy     = var.ecr_lifecycle_policy
}

# Output the ECR Repository URL for app_ecr
output "ecr_repository_url" {
  value       = aws_ecr_repository.webapp_ecr.repository_url
  description = "The URL of the ECR repository for app_ecr"
}

# Output the ECR Repository Name for app_ecr
output "ecr_repository_name" {
  value       = aws_ecr_repository.webapp_ecr.name
  description = "The URL of the ECR repository for app_ecr"
}
