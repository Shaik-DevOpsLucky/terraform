provider "aws" {
  region = "ap-southeast-5"
}

# If you're using Kubernetes as well, ensure the provider is configured for it:
provider "kubernetes" {
  host                   = var.k8s_host
  cluster_ca_certificate = base64decode(var.k8s_cluster_ca_certificate)
  client_certificate     = base64decode(var.k8s_client_certificate)
  client_key             = base64decode(var.k8s_client_key)
}
