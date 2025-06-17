# Retrieve VPC and Subnet from VPC remote state
data "terraform_remote_state" "vpc" {
  backend = "s3" # Use your backend type
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
    Project     = "dev-bold-report"
    ManagedBy   = "Terraform"
  }
}

# IAM Role for Dev-Bold-Report
resource "aws_iam_role" "dev_bold_report_role" {
  name = "Dev-Bold-Report-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [ {
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
  role       = aws_iam_role.dev_bold_report_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM instance profile to attach the role to an EC2 instance
resource "aws_iam_instance_profile" "dev_bold_report_instance_profile" {
  name = "Dev-Bold-Report-instance-profile"
  role = aws_iam_role.dev_bold_report_role.name
}

# Security Group for Dev-Bold-Report
resource "aws_security_group" "dev_bold_report_sg" {
  name        = "Dev-Bold-Report-sg"
  description = "Allow access to the Dev-Bold-Report"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.environment_tags, {
    Name = "Dev-Bold-Report Security Group"
  })
}

# Dev-Bold-Report (using Ubuntu 24.04 LTS with SSM Agent installed)
resource "aws_instance" "dev_bold_report" {
  ami                         = "ami-042b35500928461d5" # Ubuntu Server 24.04 LTS (HVM), EBS General Purpose (SSD) Volume Type
  instance_type               = "t4g.xlarge"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_1_id # Use a private subnet
  associate_public_ip_address = false # No public IP address
  vpc_security_group_ids      = [aws_security_group.dev_bold_report_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.dev_bold_report_instance_profile.id

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp2"
  }

  tags = merge(local.environment_tags, {
    Name = "Dev-Bold-Report"
  })
}

