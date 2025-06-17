# variables.tf
variable "environment" {
  description = "Environment (uat, production, etc.)"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}
