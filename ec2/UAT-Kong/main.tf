# main.tf

# Retrieve VPC from remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"
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
    Project     = "asseto-dev"
    ManagedBy   = "Terraform"
  }
}

# IAM Role for Kong Server
resource "aws_iam_role" "kong_role" {
  name = "${var.environment}-kong-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.environment_tags
}

# Attach the AmazonSSMManagedInstanceCore Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.kong_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM instance profile to attach the role to an EC2 instance
resource "aws_iam_instance_profile" "kong_instance_profile" {
  name = "kong_instance_profile"
  role = aws_iam_role.kong_role.name
}

# Security Group for Kong Server
resource "aws_security_group" "kong_sg" {
  name        = "${var.environment}-kong-sg"
  description = "Allow access to the kong server"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.environment_tags, {
    Name = "${var.environment} Kong Security Group"
  })
}

# Kong Server (using Debian 12 with SSM Agent installed)
resource "aws_instance" "kong_server" {
  ami                         = "ami-042b35500928461d5" # Ubuntu Server 24.04 LTS (HVM),EBS General Purpose (SSD) Volume Type.
  instance_type               = "t4g.large"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_1_id # Use a private subnet
  associate_public_ip_address = false                                                       # No public IP address
  vpc_security_group_ids      = [aws_security_group.kong_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.kong_instance_profile.id
  root_block_device {
    volume_size           = 50    # Size in GB
    volume_type           = "gp2" # General Purpose SSD
    delete_on_termination = true
  }

  tags = merge(local.environment_tags, {
    Name = "${var.environment} Kong Server"
  })
}

