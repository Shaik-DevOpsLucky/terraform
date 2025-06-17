# dev.tfvars
region           = "ap-southeast-5"
eks_cluster_name = "asseto-dev-eks-cluster"
desired_capacity = 3
max_capacity     = 5
min_capacity     = 3
instance_type    = "c6id.xlarge"
env              = "dev"
bucket_name      = "asseto-dev-eks"
