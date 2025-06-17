variable "aws_account_id" {
  description = "AWS Account ID"
  type        = map(string)
  default = {
    dev = "359526746093"
  }
}

variable "environment" {
  description = "Environment"
  type        = map(string)
  default = {
    dev = "dev"
  }
}
