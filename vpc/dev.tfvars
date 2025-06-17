
bucket_name          = "asseto-dev"
region               = "ap-southeast-5"                       # AWS region
environment          = "dev"                                  # Environment name (dev, prod, etc.)
vpc_cidr             = "10.4.0.0/16"                          # VPC CIDR block
public_subnet_cidrs  = ["10.4.1.0/24", "10.4.2.0/24"]         # Public subnet CIDR blocks
private_subnet_cidrs = ["10.4.3.0/24", "10.4.4.0/24"]         # Private subnet CIDR blocks
availability_zones   = ["ap-southeast-5a", "ap-southeast-5b"] # Availability zones for your subnets
