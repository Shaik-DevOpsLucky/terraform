
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

data "terraform_remote_state" "eks" {
  backend = "s3" # Replace with your backend configuration
  config = {
    bucket = var.bucket_name
    key    = "eks/terraform.tfstate" # Path to the EKS state file
    region = "ap-southeast-5"
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

# IAM Role for Bastion Host
resource "aws_iam_role" "bastion_role" {
  name = "${var.environment}-bastion-role"

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

#Inline policy to allow EKS-related actions
resource "aws_iam_role_policy" "bastion_eks_policy" {
  name = "${var.environment}-eks-access-policy"
  role = aws_iam_role.bastion_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ],
        Resource = "arn:aws:eks:ap-southeast-5:${data.aws_caller_identity.current.account_id}:cluster/${data.terraform_remote_state.eks.outputs.eks_cluster_name}"
      }
    ]
  })
}


# Attach the AmazonSSMManagedInstanceCore Policy to the Role
resource "aws_iam_role_policy_attachment" "ssm_role_policy_attachment" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an IAM instance profile to attach the role to an EC2 instance
resource "aws_iam_instance_profile" "bastion_instance_profile" {
  name = "bastion_instance_profile"
  role = aws_iam_role.bastion_role.name
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "${var.environment}-bastion-sg"
  description = "Allow access to the bastion host"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.environment_tags, {
    Name = "${var.environment} Bastion Security Group"
  })
}




# Bastion Host (using Debian 12 with SSM Agent installed)
resource "aws_instance" "bastion_host" {
  ami                         = "ami-06a9c319793848f88" # Ubuntu Server 24.04 LTS (HVM),EBS General Purpose (SSD) Volume Type.
  instance_type               = "t3.micro"
  subnet_id                   = data.terraform_remote_state.vpc.outputs.private_subnet_1_id # Use a private subnet
  associate_public_ip_address = false                                                       # No public IP address
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_instance_profile.id


  tags = merge(local.environment_tags, {
    Name = "${var.environment} Bastion Host"
  })

}
