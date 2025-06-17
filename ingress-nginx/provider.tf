provider "aws" {
  region = "ap-southeast-5"
}

provider "kubernetes" {
  config_path = "~/.kube/config" # Update if using a custom Kubernetes config file
}
