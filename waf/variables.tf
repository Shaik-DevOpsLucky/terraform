variable "alb_arn" {
  description = "ARN For AWS Load Balancer"
  type        = map(string)
  default = {
    dev     = "arn:aws:elasticloadbalancing:ap-southeast-5:359526746093:loadbalancer/app/k8s-ingressn-albingre-a28e9a3482/e3da5a3c59db29e4"
    default = "arn:aws:elasticloadbalancing:ap-southeast-5:194722412626:loadbalancer/app/k8s-ingressn-albingre-1c35e33971/66763c9b850bb660"
  }
}
