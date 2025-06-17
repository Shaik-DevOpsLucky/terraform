# variables.tf
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-5"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "asseto-dev-eks"
}

variable "desired_capacity" {
  description = "The desired capacity for the EKS worker node group"
  type        = number
  default     = 2
}

variable "max_capacity" {
  description = "The max capacity for the EKS worker node group"
  type        = number
  default     = 2
}

variable "min_capacity" {
  description = "The min capacity for the EKS worker node group"
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "Instance type for the EKS worker node group"
  type        = string
  default     = "c6g.xlarge"
}

variable "env" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  type        = string
  default     = "asseto-dev"
}
