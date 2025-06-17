variable "environment" {
  description = "Environment Naming of argocd resources"
  type        = map(string)
  default = {
    uat = "uat"
    prod    = "prod"
    dev     = "dev"
  }
}
