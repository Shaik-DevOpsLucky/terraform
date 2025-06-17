# Retrieve VPC and Subnet from VPC remote state
data "terraform_remote_state" "vpc" {
  backend = "s3" # Use your backend type
  config = {
    bucket = "asseto-dev"  # S3 bucket where VPC state is stored
    key    = "vpc/terraform.tfstate" # Key where the VPC state is saved
    region = "ap-southeast-5" # AWS region
    skip_region_validation = true
  }
}

# Data source to get the AWS Account ID
data "aws_caller_identity" "current" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.eks_cluster_name
  cluster_version = "1.31"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id

  # Pass the two private subnets to EKS
  subnet_ids = [
    data.terraform_remote_state.vpc.outputs.private_subnet_1_id,data.terraform_remote_state.vpc.outputs.private_subnet_2_id
  ]

  # Configure only private access to the EKS API
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = false

  # block for EKS managed node groups
  eks_managed_node_groups = {
    dev_nodes = {
      desired_size                 = var.desired_capacity
      max_size                     = var.max_capacity
      min_size                     = var.min_capacity
      instance_types               = [var.instance_type]
      ami_type                     = "AL2_x86_64" # Specify the Linux AMI for worker nodes
      disk_size                    = 100
      use_custom_launch_template   = false
      iam_role_additional_policies = { AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy", AmazonCloudwatchPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy" }


      # Optional, specify the EBS volume size and type here
      ebs_block_device_mappings = [{
        device_name = "/dev/xvda"
        volume_size = 100   # Size in GiB
        volume_type = "gp2" # or whatever type you need
      }]
    }
  }
  tags = {
    Name = "${var.env}-EKS-Worker-Nodes"
  }
}


# Security group for Bastion
resource "aws_security_group" "bastion-gke-sg" {
  name        = "${var.env}-bastion-gke-sg"
  description = "Security group for Bastion host"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Example ingress and egress rules (configure based on your requirements)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [ "10.4.3.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-bastion-sg"
  }
}


# Ingress rule to allow traffic from Bastion to the EKS cluster security group
resource "aws_security_group_rule" "allow_bastion_to_eks_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id # EKS cluster security group
  source_security_group_id = aws_security_group.bastion-gke-sg.id # Bastion host security group

  description = "Allow Bastion host to access the EKS control plane on HTTPS (443)"

}

# resource "aws_vpc_endpoint" "eks_private_endpoint" {
#   vpc_id            = data.terraform_remote_state.vpc.outputs.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-5.eks" # Update with your region
#   vpc_endpoint_type = "Interface"

#   # Attach the private subnets and the security group allowing traffic
#   subnet_ids         = [data.terraform_remote_state.vpc.outputs.private_subnet_1_id,data.terraform_remote_state.vpc.outputs.private_subnet_2_id]
#   security_group_ids = [module.eks.cluster_security_group_id]

#   tags = {
#     Name = "EKS Private Endpoint"
#   }
# }

locals {
  amazon_cloudwatch_observability_config = file("./amazon-cloudwatch-observability.json")
}
resource "aws_eks_addon" "amazon_cloudwatch_observability" {

  cluster_name = var.eks_cluster_name
  addon_name   = "amazon-cloudwatch-observability"
  # addon_version = "v1.7.0-eksbuild.1"
  resolve_conflicts_on_update = "OVERWRITE"

  configuration_values = local.amazon_cloudwatch_observability_config
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {

  cluster_name = var.eks_cluster_name
  addon_name   = "aws-ebs-csi-driver"
  # addon_version = "v1.35.0"
}

# Deploy Cluster Autoscaler using Helm
# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = var.eks_cluster_name
#   }

#   set {
#     name  = "awsRegion"
#     value = "ap-southeast-5"
#   }

#   set {
#     name  = "rbac.create"
#     value = "true"
#   }

#   depends_on = [module.eks]
# }

# IAM Policy for Cluster Autoscaler
data "aws_iam_policy_document" "cluster_autoscaler_policy" {
  statement {
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeInstances",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:DescribeTags",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cluster_autoscaler" {
  name   = "${var.env}-cluster-autoscaler-policy"
  policy = data.aws_iam_policy_document.cluster_autoscaler_policy.json
}

resource "aws_iam_role_policy_attachment" "attach_cluster_autoscaler_policy" {
  policy_arn = aws_iam_policy.cluster_autoscaler.arn
  role       = module.eks.eks_managed_node_groups["dev_nodes"].iam_role_name
}
output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "eks_cluster_security_group_id" {
  value = module.eks.cluster_security_group_id
}

output "eks_cluster_id" {
  value = module.eks.cluster_id
}

# Output the OIDC provider URL
output "oidc_provider_url" {
  description = "The OIDC provider URL associated with the EKS cluster"
  value       = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "eks_cluster_ca_data" {
  value = module.eks.cluster_certificate_authority_data
}
