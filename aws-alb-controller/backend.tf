terraform {
  backend "s3" {
    bucket                 = "asseto-dev"                           # The name of the S3 bucket to store Terraform state
    key                    = "aws-alb-controller/terraform.tfstate" # Path inside the S3 bucket for the state file
    region                 = "ap-southeast-5"                       # AWS region of the S3 bucket
    encrypt                = true                                   # Enable encryption for state file in S3
    skip_region_validation = true
  }
}
