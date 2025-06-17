# prod.tfvars
region           = "ap-southeast-5"
eks_cluster_name = "asseto-prod-eks-cluster"
desired_capacity = 5
max_capacity     = 6
min_capacity     = 5
instance_type    = "c6i.xlarge"
env              = "prod"
bucket_name      = "asseto-prod"
