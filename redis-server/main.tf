# Retrieve VPC and Subnet from VPC remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"  # Use your backend type
  config = {
    bucket = var.bucket_name  # S3 bucket where VPC state is stored
    key    = "vpc/terraform.tfstate"
    region = "ap-southeast-5" # AWS region
    skip_region_validation = true
  }
}

data "aws_caller_identity" "current" {}

# Local values for tags
locals {
  environment_tags = {
    Environment = var.environment
    Project     = "dev-elasticache-redis"
    ManagedBy   = "Terraform"
  }
}

# ElastiCache Subnet Group (for placing the Redis nodes in specific subnets)
resource "aws_elasticache_subnet_group" "dev_redis_subnet_group" {
  name       = "dev-redis-subnet-group"
  subnet_ids = [
  data.terraform_remote_state.vpc.outputs.private_subnet_1_id,
  data.terraform_remote_state.vpc.outputs.private_subnet_2_id
]

  tags = merge(local.environment_tags, {
    Name = "Dev Redis Subnet Group"
  })
}

# ElastiCache for Redis Cluster
resource "aws_elasticache_cluster" "dev_redis_cluster" {
  cluster_id           = "dev-redis-cluster"
  engine               = "redis"
  engine_version       = "7.0"  # Use the version that suits your needs
  node_type            = "cache.t3.medium"  # Instance type
  num_cache_nodes      = 1   # Set to 1 or more nodes for Redis cluster
  subnet_group_name    = aws_elasticache_subnet_group.dev_redis_subnet_group.name
  security_group_ids   = [aws_security_group.dev_redis_sg.id]  # Add security group for access control
  maintenance_window   = "sun:05:00-sun:09:00"
  port                 = 6379

  tags = merge(local.environment_tags, {
    Name = "Dev Redis Cluster"
  })
}

# Security Group for Dev-Redis
resource "aws_security_group" "dev_redis_sg" {
  name        = "Dev-Redis-sg"
  description = "Allow access to the Dev-Redis Cluster"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.environment_tags, {
    Name = "Dev-Redis Security Group"
  })
}

