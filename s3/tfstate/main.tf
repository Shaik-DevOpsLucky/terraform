provider "aws" {
  region = "ap-southeast-5" # Set to the specified AWS region
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "asseto-dev" # Set to your specified bucket name

  tags = {
    Name        = "AssetoDevBucket"
    Environment = "Dev"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}
