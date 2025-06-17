variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "asseto-dev-eks-cluster"
}

variable "region" {
  description = "The AWS region to deploy the EKS cluster"
  type        = string
  default     = "ap-southeast-5"
}

variable "waf_rule_priority" {
  description = "The priority of the WAF rule"
  type        = number
  default     = 1
}

variable "waf_search_string" {
  description = "The search string for the WAF rule"
  type        = string
  default     = "BadBot"
}

