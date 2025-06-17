bucket_name           = "bc-proctoring-prod-tfstate"
region                = "ap-southeast-5"
environment           = "production"
vpc_cidr              = "10.8.0.0/16"
public_subnet_cidrs   = ["10.8.1.0/24", "10.8.2.0/24"]
private_subnet_cidrs  = ["10.8.3.0/24", "10.8.4.0/24"]
availability_zones    = ["ap-southeast-5a", "ap-southeast-5b"]
peering_route_gateway = "pcx-0fc2441f890f8e66f"
