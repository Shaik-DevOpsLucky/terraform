variable "environment" {
  description = "Environment (dev, production, etc.)"
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
}

variable "root_volume_size" {
  description = "The size of the root volume in GB"
  type        = number
  default     = 200
}

