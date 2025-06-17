# backend.tf
terraform {
  backend "s3" {
    bucket                 = "asseto-dev"     # Your S3 bucket name
    key                    = "ec2/uat-kong"    # Path to store the state file
    region                 = "ap-southeast-5" # Region where the S3 bucket is located
    encrypt                = true             # Enable server-side encryption for state
    skip_region_validation = true
  }
}
