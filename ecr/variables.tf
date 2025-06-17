# Environment (e.g., dev, staging, prod)
variable "environment" {
  description = "The environment for this infrastructure (e.g., dev, staging, production)"
  type        = string
}

# ECR Repository Name
variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type        = string
}

# ECR Image Tag Mutability
variable "ecr_image_tag_mutability" {
  description = "Whether to allow overwriting tags in the ECR repository (MUTABLE or IMMUTABLE)"
  type        = string
  default     = "IMMUTABLE"
}

# Enable image scanning
variable "ecr_enable_image_scanning" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

# Lifecycle Policy for ECR (JSON string)
variable "ecr_lifecycle_policy" {
  description = "The lifecycle policy to apply to the ECR repository"
  type        = string
  default     = <<POLICY
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 30 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 30
      },
      "action": {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Keep only 5 tagged images with the prefix 'release-'",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["proctoring-"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
POLICY
}

# S3 bucket name for Terraform state
variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string

}
