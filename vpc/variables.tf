# S3 Bucket Name
variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
}

# AWS Region
variable "region" {
  description = "The AWS region"
  type        = string
}

# Environment Name
variable "environment" {
  description = "The environment name (e.g., dev, prod)"
  type        = string
}

# VPC CIDR Block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

# Public Subnet CIDR Blocks
variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

# Private Subnet CIDR Blocks
variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

# Availability Zones
variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

# Tags for resources
variable "tags" {
  description = "Tags to be applied to resources"
  type        = map(string)
  default = {
    "Environment" = "dev"
    "Project"     = "asseto-dev"
  }
}
