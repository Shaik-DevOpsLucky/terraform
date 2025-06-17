provider "aws" {
  region = "ap-southeast-5"
}

# Helm provider with Kubernetes configuration
provider "helm" {
  kubernetes {
    host = "https://B2509F9B51C1AE2205DD8FEBD5F8960B.yl4.ap-southeast-5.eks.amazonaws.com" # Replace with your actual Kubernetes cluster endpoint
    # Include additional parameters like token or certificate_authority if needed
  }
}

# Use existing VPC
data "aws_vpc" "existing" {
  id = "vpc-0d91ca87aa500dc48" # Existing VPC ID
}

# Use existing subnets
data "aws_subnet" "subnet_1" {
  vpc_id = data.aws_vpc.existing.id
  filter {
    name   = "cidr-block"
    values = ["10.4.3.0/24"]
  }
}

data "aws_subnet" "subnet_2" {
  vpc_id = data.aws_vpc.existing.id
  filter {
    name   = "cidr-block"
    values = ["10.4.4.0/24"]
  }
}

# Security Group for EKS
resource "aws_security_group" "eks_sg" {
  name        = "eks-security-group"
  description = "EKS security group"
  vpc_id      = data.aws_vpc.existing.id
}

# Create new IAM Role for EKS
resource "aws_iam_role" "eks_role" {
  name = "asseto-dev-eks-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

# Create the missing policy for VPC Resource Controller (if it doesn't exist)
resource "aws_iam_policy" "eks_vpc_resource_controller_policy" {
  name        = "CustomEKS_VPCResourceControllerPolicy"
  description = "Custom policy for EKS VPC resource controller permissions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateSecurityGroup",
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVpc",
          "ec2:DeleteSubnet",
          "ec2:ModifyVpcAttribute",
          "ec2:ModifySubnetAttribute",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach necessary policies to the EKS role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

# Attach the custom policy for VPC Resource Controller
resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = aws_iam_policy.eks_vpc_resource_controller_policy.arn
}

# EKS Cluster
resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids         = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
    security_group_ids = [aws_security_group.eks_sg.id]
  }

  depends_on = [aws_iam_role.eks_role]
}

# Helm release for AWS Load Balancer Controller
resource "helm_release" "aws_load_balancer_controller" {
  name      = "aws-load-balancer-controller"
  chart     = "../helm-charts/aws-load-balancer-controller"
  namespace = "kube-system"
}

# ALB Load Balancer
resource "aws_lb" "alb" {
  name                       = "asseto-dev-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.eks_sg.id]
  subnets                    = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]
  enable_deletion_protection = false
  enable_http2               = true
}

# AWS WAF WebACL
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "asseto-dev-web-acl"
  description = "Web ACL for my ALB"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }

  rule {
    name     = "Rule1"
    priority = var.waf_rule_priority
    action {
      allow {}
    }
    statement {
      byte_match_statement {
        field_to_match {
          single_header {
            name = "user-agent"
          }
        }
        positional_constraint = "CONTAINS"
        search_string         = var.waf_search_string

        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    visibility_config {
      sampled_requests_enabled   = true
      cloudwatch_metrics_enabled = true
      metric_name                = "Rule1"
    }
  }

  visibility_config {
    sampled_requests_enabled   = true
    cloudwatch_metrics_enabled = true
    metric_name                = "waf-metrics"
  }
}

# Attach WAF WebACL to ALB
resource "aws_wafv2_web_acl_association" "waf_association" {
  resource_arn = aws_lb.alb.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}

